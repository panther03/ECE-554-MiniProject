module proc (
   // Clock and reset
   input         clk,
   input         rst_n,
   // Instruction memory signals
   output [15:0] iaddr_o,
   input  [15:0] inst_i,
   // Data memory signals
   output [15:0] daddr_o,
   output        we_o,
   output        re_o,
   output [15:0] data_proc_to_mem_o,
   input  [15:0] data_mem_to_proc_i,
   // Error and Halt status,
   output        err_o,
   output        halt_o
);

   // Disclaimer: This codebase used dff.v modules instead of always blocks
   // due to CS552 restricting certain Verilog features
   // I have converted these into always blocks, however I have done so
   // lazily to avoid introducing new logic bugs
   // The reasoning being that this codebase will not be with us for the whole semester (it will likely have to be rewritten.)

   // I have also not converted the rest of the codebase to fit the style guidelines in README.md.

   ////////////////////////
   // fetch block wires //
   //////////////////////
   wire [15:0] pc_inc;
   wire stall, flush;
   wire fetch_err;

   /////////////////////////////
   // IF_ID transition wires //
   ///////////////////////////

   logic [15:0] IF_ID_pc_inc_in, IF_ID_pc_inc_out;
   logic [15:0] IF_ID_inst_in, IF_ID_inst_out, IF_ID_inst_out_temp;

   //////////////////////////
   // control block wires //
   ////////////////////////

   wire [6:0] op_word;
   wire ctrl_err;

   wire [3:0] AluOp;
   wire [1:0] InstFmt, JType, CondOp;
   wire RegWrite, MemWrite, MemRead,
        MemToReg, AluSrc, XtendSel,
        Exc, Rtn, Halt;

   /////////////////////////
   // decode block wires //
   ///////////////////////

   wire [15:0] reg1, reg2, imm, ofs;
   wire bypass_reg1, bypass_reg2;
   wire decode_err;

   /////////////////////////////
   // ID_EX transition wires //
   ///////////////////////////

   logic ID_EX_ctrl_RegWrite_in, ID_EX_ctrl_RegWrite_out;
   logic ID_EX_ctrl_MemWrite_in, ID_EX_ctrl_MemWrite_out;
   logic ID_EX_ctrl_MemRead_in, ID_EX_ctrl_MemRead_out;
   logic ID_EX_ctrl_MemToReg_in, ID_EX_ctrl_MemToReg_out;
   logic ID_EX_ctrl_AluSrc_in, ID_EX_ctrl_AluSrc_out;
   logic [1:0] ID_EX_ctrl_InstFmt_in, ID_EX_ctrl_InstFmt_out;
   logic [1:0] ID_EX_ctrl_JType_in, ID_EX_ctrl_JType_out;
   logic [3:0] ID_EX_ctrl_AluOp_in, ID_EX_ctrl_AluOp_out;

   logic ID_EX_ctrl_Halt_in, ID_EX_ctrl_Halt_out;

   logic [15:0] ID_EX_reg1_in, ID_EX_reg1_out;
   logic [15:0] ID_EX_reg2_in, ID_EX_reg2_out;
   logic [15:0] ID_EX_imm_in, ID_EX_imm_out;

   logic [15:0] ID_EX_pc_inc_in, ID_EX_pc_inc_out;
   logic [15:0] ID_EX_inst_in, ID_EX_inst_out;

   //////////////////////////
   // execute block wires //
   ////////////////////////

   wire [15:0] alu_out;
   wire [15:0] reg1_frwrd, reg2_frwrd;
   reg [2:0] writesel;
   wire ex_err;

   //////////////////////////////
   // EX_MEM transition wires //
   ////////////////////////////

   logic EX_MEM_ctrl_RegWrite_in, EX_MEM_ctrl_RegWrite_out;
   logic EX_MEM_ctrl_MemRead_in,  EX_MEM_ctrl_MemRead_out;
   logic EX_MEM_ctrl_MemWrite_in, EX_MEM_ctrl_MemWrite_out;
   logic EX_MEM_ctrl_MemToReg_in, EX_MEM_ctrl_MemToReg_out;

   logic EX_MEM_ctrl_Halt_in, EX_MEM_ctrl_Halt_out;

   logic [15:0] EX_MEM_alu_out_in,  EX_MEM_alu_out_out;
   logic [15:0] EX_MEM_reg2_in, EX_MEM_reg2_out;
   logic [2:0] EX_MEM_writesel_in, EX_MEM_writesel_out;

   //////////////////////////////
   // MEM_WB transition wires //
   ////////////////////////////

   logic MEM_WB_ctrl_RegWrite_in, MEM_WB_ctrl_RegWrite_out;
   logic MEM_WB_ctrl_MemToReg_in, MEM_WB_ctrl_MemToReg_out;

   logic MEM_WB_ctrl_Halt_in, MEM_WB_ctrl_Halt_out;

   logic [2:0] MEM_WB_writesel_in, MEM_WB_writesel_out;
   logic [15:0] MEM_WB_alu_out_in, MEM_WB_alu_out_out;
   logic [15:0] MEM_WB_mem_out_in, MEM_WB_mem_out_out;

   ////////////////////////////
   // writeback block wires //
   //////////////////////////

   wire [15:0] write_in;

   ////////////////////////////
   // forwarding unit wires //
   //////////////////////////

   wire frwrd_MEM_EX_opA, frwrd_MEM_EX_opB;
   wire frwrd_WB_EX_opA, frwrd_WB_EX_opB;
   wire frwrd_EX_ID_opA;

   //////////////////
   // fetch block //
   ////////////////   

   // Don't use the normal reg_frwrd signal here,
   // we are only interested in the special EX->ID forward case,
   // and standard RF bypass case.
   wire [15:0] reg1_frwrd_fetch = frwrd_EX_ID_opA ? EX_MEM_alu_out_out : reg1;

   // halt from all stages is passed to stop PC increment,
   // but the testbench should only see Halt from MEM_WB.
   wire all_halts = Halt | ID_EX_ctrl_Halt_out | EX_MEM_ctrl_Halt_out | MEM_WB_ctrl_Halt_out;

   fetch iFETCH(.clk(clk), .rst_n(rst_n), .fetch_err(fetch_err), 
      .stall(stall), .flush(flush), .JType(JType), .CondOp(CondOp),
      .iaddr(iaddr_o), .pc_inc_out(pc_inc), .pc_inc_in(IF_ID_pc_inc_out), .reg1(reg1_frwrd_fetch),
      .Halt(all_halts), .Rtn(Rtn), .Exc(Exc), .ofs(ofs), .imm(imm));
   
   ///////////////////////
   // IF/ID transition //
   /////////////////////

   // flip bit 11 to default to NOP instead of HALT when we stall
   assign IF_ID_inst_in = inst_i ^ 16'h0800;
   assign IF_ID_pc_inc_in = pc_inc;   
   
   // If we get a stall or halt, we recirculate values here.
   // If we get a flush, we load in 0 (nop) for the instruction.
   wire [31:0] IF_ID_reg_in = (all_halts | stall) ? {IF_ID_pc_inc_out,IF_ID_inst_out_temp}
                            : (flush ? {IF_ID_pc_inc_out,16'h0} : {IF_ID_pc_inc_in, IF_ID_inst_in});

   always @(posedge clk, negedge rst_n)
      if (!rst_n) begin
         IF_ID_inst_out_temp <= 0;
         IF_ID_pc_inc_out <= 0;
      end else begin
         IF_ID_inst_out_temp <= IF_ID_reg_in[15:0];
         IF_ID_pc_inc_out <= IF_ID_reg_in[31:16];
      end

   // Since we flipped at input, flip at output as well.
   assign IF_ID_inst_out = IF_ID_inst_out_temp ^ 16'h0800;


   ////////////////////
   // control block //
   //////////////////

   // From the schematic, this is part of decode stage,
   // but listed as top level for convenience.

   assign op_word = {IF_ID_inst_out[15:11],IF_ID_inst_out[1:0]};
   control iCONTROL(.op_word(op_word), .ctrl_err(ctrl_err),
      .RegWrite(RegWrite), .MemWrite(MemWrite), .MemRead(MemRead),
      .InstFmt(InstFmt), .MemToReg(MemToReg), .AluSrc(AluSrc),
      .AluOp(AluOp), .CondOp(CondOp), .JType(JType),
      .XtendSel(XtendSel), .Rtn(Rtn), .Exc(Exc), .Halt(Halt));

   ///////////////////
   // decode block //
   /////////////////

   decode iDECODE(.clk(clk), .rst_n(rst_n), .decode_err(decode_err),
      .inst(IF_ID_inst_out), .writesel(MEM_WB_writesel_out),
      .bypass_reg1(bypass_reg1), .bypass_reg2(bypass_reg2),
      .write_in(write_in), .reg1(reg1), .reg2(reg2), .imm(imm), .ofs(ofs),
      .InstFmt(InstFmt), .JType(JType), .XtendSel(XtendSel), .RegWrite(MEM_WB_ctrl_RegWrite_out));

   ///////////////////////
   // ID/EX transition //
   /////////////////////

   // squash all control signals to 0 if we stall
   assign ID_EX_ctrl_RegWrite_in = stall ? 0 : RegWrite;
   assign ID_EX_ctrl_MemWrite_in = stall ? 0 : MemWrite;
   assign ID_EX_ctrl_MemRead_in = stall ? 0 : MemRead;
   assign ID_EX_ctrl_MemToReg_in = stall ? 0 : MemToReg;
   assign ID_EX_ctrl_AluSrc_in = stall ? 0 : AluSrc;
   assign ID_EX_ctrl_InstFmt_in = stall ? 0 :InstFmt;
   assign ID_EX_ctrl_JType_in = stall ? 0 : JType;
   assign ID_EX_ctrl_AluOp_in = stall ? 0 : AluOp;
   assign ID_EX_ctrl_Halt_in = stall ? 0 : Halt;

   assign ID_EX_reg1_in = reg1;
   assign ID_EX_reg2_in = reg2;
   assign ID_EX_imm_in = imm;

   // squash inst to nop, control bits don't matter
   // because the following stages only use
   // reg fields & imm etc.
   assign ID_EX_inst_in = stall ? 0 : IF_ID_inst_out;
   assign ID_EX_pc_inc_in = IF_ID_pc_inc_out;

   always @(posedge clk, negedge rst_n) 
      if (!rst_n) begin
         ID_EX_ctrl_RegWrite_out <= 0;
         ID_EX_ctrl_MemWrite_out <= 0;
         ID_EX_ctrl_MemRead_out <= 0;
         ID_EX_ctrl_MemToReg_out <= 0;
         ID_EX_ctrl_AluSrc_out <= 0;
         ID_EX_ctrl_InstFmt_out <= 0;
         ID_EX_ctrl_JType_out <= 0;
         ID_EX_ctrl_AluOp_out <= 0;
         ID_EX_reg1_out <= 0;
         ID_EX_reg2_out <= 0;
         ID_EX_imm_out <= 0;
         ID_EX_pc_inc_out <= 0;
         ID_EX_inst_out <= 0;
         ID_EX_ctrl_Halt_out <= 0;
      end else begin
         ID_EX_ctrl_RegWrite_out <= ID_EX_ctrl_RegWrite_in;
         ID_EX_ctrl_MemWrite_out <= ID_EX_ctrl_MemWrite_in;
         ID_EX_ctrl_MemRead_out <= ID_EX_ctrl_MemRead_in;
         ID_EX_ctrl_MemToReg_out <= ID_EX_ctrl_MemToReg_in;
         ID_EX_ctrl_AluSrc_out <= ID_EX_ctrl_AluSrc_in;
         ID_EX_ctrl_InstFmt_out <= ID_EX_ctrl_InstFmt_in;
         ID_EX_ctrl_JType_out <= ID_EX_ctrl_JType_in;
         ID_EX_ctrl_AluOp_out <= ID_EX_ctrl_AluOp_in;
         ID_EX_reg1_out <= ID_EX_reg1_in;
         ID_EX_reg2_out <= ID_EX_reg2_in;
         ID_EX_imm_out <= ID_EX_imm_in;
         ID_EX_pc_inc_out <= ID_EX_pc_inc_in;
         ID_EX_inst_out <= ID_EX_inst_in;
         ID_EX_ctrl_Halt_out <= ID_EX_ctrl_Halt_in;
      end

   ////////////////////
   // execute block //
   //////////////////
  
   assign reg1_frwrd = frwrd_MEM_EX_opA ? EX_MEM_alu_out_out : (frwrd_WB_EX_opA ? write_in : ID_EX_reg1_out);
   assign reg2_frwrd = frwrd_MEM_EX_opB ? EX_MEM_alu_out_out : (frwrd_WB_EX_opB ? write_in : ID_EX_reg2_out);
   
   execute iEXECUTE(.ex_err(ex_err), 
      .reg1(reg1_frwrd), .reg2(reg2_frwrd), .imm(ID_EX_imm_out),
      .pc_inc(ID_EX_pc_inc_out), .alu_out(alu_out),
      .AluOp(ID_EX_ctrl_AluOp_out), .JType(ID_EX_ctrl_JType_out),
      .InstFmt(ID_EX_ctrl_InstFmt_out), .AluSrc(ID_EX_ctrl_AluSrc_out));

   always @* case (ID_EX_ctrl_InstFmt_out)
        2'b00 : writesel = (ID_EX_ctrl_JType_out == 2'b01) ? 3'h7 : ID_EX_inst_out[10:8];
        2'b01 : writesel = (ID_EX_inst_out[15:11] == 5'b10011) ? ID_EX_inst_out[10:8] : ID_EX_inst_out[7:5]; // exception case for STU (needs to write to Rs)
        2'b10 : writesel = ID_EX_inst_out[4:2];
        2'b11 : writesel = 3'h7;
    endcase

   ////////////////////////
   // EX/MEM transition //
   //////////////////////

   assign EX_MEM_ctrl_RegWrite_in = ID_EX_ctrl_RegWrite_out;
   assign EX_MEM_ctrl_MemWrite_in = ID_EX_ctrl_MemWrite_out;
   assign EX_MEM_ctrl_MemRead_in  = ID_EX_ctrl_MemRead_out;
   assign EX_MEM_ctrl_MemToReg_in = ID_EX_ctrl_MemToReg_out;

   assign EX_MEM_ctrl_Halt_in = ID_EX_ctrl_Halt_out;

   assign EX_MEM_alu_out_in = alu_out;
   assign EX_MEM_reg2_in = reg2_frwrd;
   assign EX_MEM_writesel_in = writesel;

   always @(posedge clk, negedge rst_n)
      if (!rst_n) begin
         EX_MEM_ctrl_RegWrite_out <= 0;
         EX_MEM_ctrl_MemRead_out  <= 0;
         EX_MEM_ctrl_MemWrite_out <= 0;
         EX_MEM_ctrl_MemToReg_out <= 0;
         EX_MEM_alu_out_out <= 0;
         EX_MEM_reg2_out <= 0;
         EX_MEM_writesel_out <= 0;
         EX_MEM_ctrl_Halt_out <= 0;
      end else begin
         EX_MEM_ctrl_RegWrite_out <= EX_MEM_ctrl_RegWrite_in;
         EX_MEM_ctrl_MemRead_out  <= EX_MEM_ctrl_MemRead_in;
         EX_MEM_ctrl_MemWrite_out <= EX_MEM_ctrl_MemWrite_in;
         EX_MEM_ctrl_MemToReg_out <= EX_MEM_ctrl_MemToReg_in;
         EX_MEM_alu_out_out <= EX_MEM_alu_out_in;
         EX_MEM_reg2_out <= EX_MEM_reg2_in;
         EX_MEM_writesel_out <= EX_MEM_writesel_in;
         EX_MEM_ctrl_Halt_out <= EX_MEM_ctrl_Halt_in;
      end

   ///////////////////
   // memory block //
   /////////////////

   // this has been moved outside of proc.v!

   assign daddr_o = EX_MEM_alu_out_out;
   assign data_proc_to_mem_o = EX_MEM_reg2_out;
   assign we_o = EX_MEM_ctrl_MemWrite_out;
   assign re_o = EX_MEM_ctrl_MemRead_out;

   ////////////////////////
   // MEM/WB transition //
   //////////////////////

   assign MEM_WB_ctrl_RegWrite_in = EX_MEM_ctrl_RegWrite_out;
   assign MEM_WB_ctrl_MemToReg_in = EX_MEM_ctrl_MemToReg_out;
   assign MEM_WB_ctrl_Halt_in = EX_MEM_ctrl_Halt_out;

   assign MEM_WB_alu_out_in = EX_MEM_alu_out_out;
   assign MEM_WB_mem_out_in = data_mem_to_proc_i;
   assign MEM_WB_writesel_in = EX_MEM_writesel_out;

   always @(posedge clk, negedge rst_n)
      if (!rst_n) begin
         MEM_WB_ctrl_RegWrite_out <= 0;
         MEM_WB_ctrl_MemToReg_out <= 0;
         MEM_WB_ctrl_Halt_out <= 0;
         MEM_WB_writesel_out <= 0;
         MEM_WB_alu_out_out <= 0;
         MEM_WB_mem_out_out <= 0;
      end else begin
         MEM_WB_ctrl_RegWrite_out <= MEM_WB_ctrl_RegWrite_in;
         MEM_WB_ctrl_MemToReg_out <= MEM_WB_ctrl_MemToReg_in;
         MEM_WB_ctrl_Halt_out <= MEM_WB_ctrl_Halt_in;
         MEM_WB_writesel_out <= MEM_WB_writesel_in;
         MEM_WB_alu_out_out <= MEM_WB_alu_out_in;
         MEM_WB_mem_out_out <= MEM_WB_mem_out_in;
      end

   //////////////////////
   // writeback block //
   ////////////////////
   
   assign write_in = MEM_WB_ctrl_MemToReg_out ? MEM_WB_mem_out_out : MEM_WB_alu_out_out;
   assign halt_o = MEM_WB_ctrl_Halt_out;

   ////////////////////////////
   // hazard detection unit //
   //////////////////////////

   hazard iHAZARD (.IF_ID_reg1(IF_ID_inst_out[10:8]),.IF_ID_reg2(IF_ID_inst_out[7:5]),
      .IF_ID_is_branch(JType[0]),.ID_EX_is_load(ID_EX_ctrl_MemRead_out & ID_EX_ctrl_RegWrite_out),
      .ID_EX_ctrl_regw(ID_EX_ctrl_RegWrite_out),.EX_MEM_ctrl_regw(EX_MEM_ctrl_RegWrite_out),
      .ID_EX_regw(writesel),.EX_MEM_regw(EX_MEM_writesel_out),.stall(stall));

   //////////////////////
   // forwarding unit //
   ////////////////////

   forward iFORWARD (.EX_MEM_regw(EX_MEM_writesel_out),.MEM_WB_regw(MEM_WB_writesel_out),
      .IF_ID_reg1(IF_ID_inst_out[10:8]),.IF_ID_reg2(IF_ID_inst_out[7:5]),
      .ID_EX_reg1(ID_EX_inst_out[10:8]),.ID_EX_reg2(ID_EX_inst_out[7:5]),
      .frwrd_EX_ID_opA(frwrd_EX_ID_opA),.bypass_reg1(bypass_reg1),.bypass_reg2(bypass_reg2),
      .frwrd_MEM_EX_opA(frwrd_MEM_EX_opA),.frwrd_MEM_EX_opB(frwrd_MEM_EX_opB),
      .frwrd_WB_EX_opA(frwrd_WB_EX_opA),.frwrd_WB_EX_opB(frwrd_WB_EX_opB),
      .EX_MEM_ctrl_regw(EX_MEM_ctrl_RegWrite_out),.MEM_WB_ctrl_regw(MEM_WB_ctrl_RegWrite_out));

   // error handling
   assign err_o = ex_err | ctrl_err | fetch_err | decode_err;

   // Memory signals


endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
