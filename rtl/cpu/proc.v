/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module proc (/*AUTOARG*/
   // Error signal
   err, 
   // Clock and reset
   clk, rst_n,
   // Instruction memory signals
   iaddr, inst,
   // Data memory signals
   daddr, wr, en, data_in, data_out
   );

   output err;

   input clk;
   input rst_n;

   // these addresses are 16-bit despite the physical memory
   // they are going to not being that large
   // this is to allow for MMIO
   output [15:0] iaddr;
   input [15:0] inst;

   output [15:0] daddr;
   output wr;
   output en;
   output [15:0] data_in;
   input  [15:0] data_out;



   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines

   ////////////////////////
   // fetch block wires //
   //////////////////////
   wire [15:0] pc_inc;
   wire stall, flush;
   wire fetch_err;

   /////////////////////////////
   // IF_ID transition wires //
   ///////////////////////////

   wire [15:0] IF_ID_pc_inc_in, IF_ID_pc_inc_out;
   wire [15:0] IF_ID_inst_in, IF_ID_inst_out_temp, IF_ID_inst_out;

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

   wire ID_EX_ctrl_RegWrite_in, ID_EX_ctrl_RegWrite_out;
   wire ID_EX_ctrl_MemWrite_in, ID_EX_ctrl_MemWrite_out;
   wire ID_EX_ctrl_MemRead_in, ID_EX_ctrl_MemRead_out;
   wire ID_EX_ctrl_MemToReg_in, ID_EX_ctrl_MemToReg_out;
   wire ID_EX_ctrl_AluSrc_in, ID_EX_ctrl_AluSrc_out;
   wire [1:0] ID_EX_ctrl_InstFmt_in, ID_EX_ctrl_InstFmt_out;
   wire [1:0] ID_EX_ctrl_CondOp_in, ID_EX_ctrl_CondOp_out;
   wire [1:0] ID_EX_ctrl_JType_in, ID_EX_ctrl_JType_out;
   wire [3:0] ID_EX_ctrl_AluOp_in, ID_EX_ctrl_AluOp_out;

   wire ID_EX_ctrl_Halt_in, ID_EX_ctrl_Halt_out;
   wire ID_EX_ctrl_Exc_in, ID_EX_ctrl_Exc_out;

   wire [15:0] ID_EX_reg1_in, ID_EX_reg1_out;
   wire [15:0] ID_EX_reg2_in, ID_EX_reg2_out;
   wire [15:0] ID_EX_ofs_in, ID_EX_ofs_out;
   wire [15:0] ID_EX_imm_in, ID_EX_imm_out;

   wire [15:0] ID_EX_pc_inc_in, ID_EX_pc_inc_out;
   wire [15:0] ID_EX_inst_in, ID_EX_inst_out;

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

   wire EX_MEM_ctrl_RegWrite_in, EX_MEM_ctrl_RegWrite_out;
   wire EX_MEM_ctrl_MemWrite_in, EX_MEM_ctrl_MemWrite_out;
   wire EX_MEM_ctrl_MemRead_in, EX_MEM_ctrl_MemRead_out;
   wire EX_MEM_ctrl_MemToReg_in, EX_MEM_ctrl_MemToReg_out;

   wire EX_MEM_ctrl_Halt_in, EX_MEM_ctrl_Halt_out;
   wire EX_MEM_ctrl_Exc_in, EX_MEM_ctrl_Exc_out;

   wire [15:0] EX_MEM_alu_out_in,  EX_MEM_alu_out_out;
   wire [15:0] EX_MEM_reg2_in, EX_MEM_reg2_out;
   wire [2:0] EX_MEM_writesel_in, EX_MEM_writesel_out;

   /////////////////////////
   // memory block wires //
   ///////////////////////

   wire [15:0] mem_out;

   //////////////////////////////
   // MEM_WB transition wires //
   ////////////////////////////

   wire MEM_WB_ctrl_RegWrite_in, MEM_WB_ctrl_RegWrite_out;
   wire MEM_WB_ctrl_MemToReg_in, MEM_WB_ctrl_MemToReg_out;

   wire MEM_WB_ctrl_Halt_in, MEM_WB_ctrl_Halt_out;
   wire MEM_WB_ctrl_Exc_in, MEM_WB_ctrl_Exc_out;

   wire [2:0] MEM_WB_writesel_in, MEM_WB_writesel_out;
   wire [15:0] MEM_WB_alu_out_in, MEM_WB_alu_out_out;
   wire [15:0] MEM_WB_mem_out_in, MEM_WB_mem_out_out;

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
      .inst(inst), .stall(stall), .flush(flush), .JType(JType), .CondOp(CondOp),
      .iaddr(iaddr), .pc_inc_out(pc_inc), .pc_inc_in(IF_ID_pc_inc_out), .reg1(reg1_frwrd_fetch),
      .Halt(all_halts), .Rtn(Rtn), .Exc(Exc), .ofs(ofs), .imm(imm));
   
   ///////////////////////
   // IF/ID transition //
   /////////////////////

   // flip bit 11 to default to NOP instead of HALT
   assign IF_ID_inst_in = inst ^ 16'h0800;
   assign IF_ID_pc_inc_in = pc_inc;   
   
   // If we get a stall or halt, we recirculate values here.
   // If we get a flush, we load in 0 (nop) for the instruction.
   wire [31:0] IF_ID_reg_in = (all_halts | stall) ? {IF_ID_pc_inc_out,IF_ID_inst_out_temp}
                            : (flush ? {IF_ID_pc_inc_out,16'h0} : {IF_ID_pc_inc_in, IF_ID_inst_in});

   dff IF_ID_reg [31:0] (.clk(clk), .rst_n(rst_n),
      .d(IF_ID_reg_in), .q({IF_ID_pc_inc_out,IF_ID_inst_out_temp}));

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

   // squash all control signals to 0 if we stalls
   assign ID_EX_ctrl_RegWrite_in = stall ? 0 : RegWrite;
   assign ID_EX_ctrl_MemWrite_in = stall ? 0 : MemWrite;
   assign ID_EX_ctrl_MemRead_in = stall ? 0 : MemRead;
   assign ID_EX_ctrl_MemToReg_in = stall ? 0 : MemToReg;
   assign ID_EX_ctrl_AluSrc_in = stall ? 0 : AluSrc;
   assign ID_EX_ctrl_InstFmt_in = stall ? 0 :InstFmt;
   assign ID_EX_ctrl_CondOp_in =  stall ? 0 : CondOp;
   assign ID_EX_ctrl_JType_in = stall ? 0 : JType;
   assign ID_EX_ctrl_AluOp_in = stall ? 0 : AluOp;

   assign ID_EX_ctrl_Halt_in = stall ? 0 : Halt;
   assign ID_EX_ctrl_Exc_in = stall ? 0 : Exc;

   assign ID_EX_reg1_in = reg1;
   assign ID_EX_reg2_in = reg2;
   assign ID_EX_ofs_in = ofs;
   assign ID_EX_imm_in = imm;

   // squash inst to nop, control bits don't matter
   // because the following stages only use
   // reg fields & imm etc.
   assign ID_EX_inst_in = stall ? 0 : IF_ID_inst_out;
   assign ID_EX_pc_inc_in = IF_ID_pc_inc_out;

   dff ID_EX_reg [112:0] (.clk(clk), .rst_n(rst_n),
      .d({ID_EX_ctrl_RegWrite_in, ID_EX_ctrl_MemWrite_in, ID_EX_ctrl_MemRead_in, ID_EX_ctrl_MemToReg_in, ID_EX_ctrl_AluSrc_in, ID_EX_ctrl_InstFmt_in, ID_EX_ctrl_CondOp_in, ID_EX_ctrl_JType_in, ID_EX_ctrl_AluOp_in, ID_EX_reg1_in, ID_EX_reg2_in, ID_EX_ofs_in, ID_EX_imm_in, ID_EX_pc_inc_in, ID_EX_inst_in, ID_EX_ctrl_Halt_in, ID_EX_ctrl_Exc_in}),
      .q({ID_EX_ctrl_RegWrite_out, ID_EX_ctrl_MemWrite_out, ID_EX_ctrl_MemRead_out, ID_EX_ctrl_MemToReg_out, ID_EX_ctrl_AluSrc_out, ID_EX_ctrl_InstFmt_out, ID_EX_ctrl_CondOp_out, ID_EX_ctrl_JType_out, ID_EX_ctrl_AluOp_out, ID_EX_reg1_out, ID_EX_reg2_out, ID_EX_ofs_out, ID_EX_imm_out, ID_EX_pc_inc_out, ID_EX_inst_out, ID_EX_ctrl_Halt_out, ID_EX_ctrl_Exc_out}));

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
   assign EX_MEM_ctrl_MemRead_in = ID_EX_ctrl_MemRead_out;
   assign EX_MEM_ctrl_MemToReg_in = ID_EX_ctrl_MemToReg_out;

   assign EX_MEM_ctrl_Halt_in = ID_EX_ctrl_Halt_out;
   assign EX_MEM_ctrl_Exc_in = ID_EX_ctrl_Exc_out;

   assign EX_MEM_alu_out_in = alu_out;
   assign EX_MEM_reg2_in = reg2_frwrd;
   assign EX_MEM_writesel_in = writesel;

   dff EX_MEM_reg [40:0] (.clk(clk), .rst_n(rst_n),
      .d({EX_MEM_ctrl_RegWrite_in, EX_MEM_ctrl_MemWrite_in, EX_MEM_ctrl_MemRead_in, EX_MEM_ctrl_MemToReg_in, EX_MEM_alu_out_in, EX_MEM_reg2_in, EX_MEM_writesel_in, EX_MEM_ctrl_Halt_in, EX_MEM_ctrl_Exc_in}),
      .q({EX_MEM_ctrl_RegWrite_out, EX_MEM_ctrl_MemWrite_out, EX_MEM_ctrl_MemRead_out, EX_MEM_ctrl_MemToReg_out, EX_MEM_alu_out_out, EX_MEM_reg2_out, EX_MEM_writesel_out, EX_MEM_ctrl_Halt_out, EX_MEM_ctrl_Exc_out}));

   ///////////////////
   // memory block //
   /////////////////

   // this has been moved outside of proc.v!

   assign daddr = EX_MEM_alu_out_out;
   assign mem_out = data_out;
   assign data_in = EX_MEM_reg2_out;
   assign en = EX_MEM_ctrl_MemRead_out | EX_MEM_ctrl_MemWrite_out;
   assign wr = EX_MEM_ctrl_MemWrite_out;

   ////////////////////////
   // MEM/WB transition //
   //////////////////////

   assign MEM_WB_ctrl_RegWrite_in = EX_MEM_ctrl_RegWrite_out;
   assign MEM_WB_ctrl_MemToReg_in = EX_MEM_ctrl_MemToReg_out;
   assign MEM_WB_ctrl_Halt_in = EX_MEM_ctrl_Halt_out;
   assign MEM_WB_ctrl_Exc_in = EX_MEM_ctrl_Exc_out;

   assign MEM_WB_alu_out_in = EX_MEM_alu_out_out;
   assign MEM_WB_mem_out_in = mem_out;
   assign MEM_WB_writesel_in = EX_MEM_writesel_out;

   dff MEM_WB_reg [38:0] (.clk(clk),.rst_n(rst_n), 
      .d({MEM_WB_ctrl_RegWrite_in, MEM_WB_ctrl_MemToReg_in, MEM_WB_ctrl_Halt_in, MEM_WB_ctrl_Exc_in, MEM_WB_writesel_in, MEM_WB_alu_out_in, MEM_WB_mem_out_in}),
      .q({MEM_WB_ctrl_RegWrite_out, MEM_WB_ctrl_MemToReg_out, MEM_WB_ctrl_Halt_out, MEM_WB_ctrl_Exc_out, MEM_WB_writesel_out, MEM_WB_alu_out_out, MEM_WB_mem_out_out}));

   //////////////////////
   // writeback block //
   ////////////////////
   
   assign write_in = MEM_WB_ctrl_MemToReg_out ? MEM_WB_mem_out_out : MEM_WB_alu_out_out;

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
   assign err = ex_err | ctrl_err | fetch_err | decode_err;

   // Memory signals


endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
