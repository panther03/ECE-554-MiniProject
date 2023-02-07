module fetch (pc_inc_in, pc_inc_out, iaddr,
              reg1, ofs, imm, stall, flush,
              JType, CondOp, Halt, Rtn, Exc,
              clk, rst_n, fetch_err);

	input clk, rst_n;
    
    input [15:0] reg1, imm, ofs;
    input [15:0] pc_inc_in;
    input stall;

    output [15:0] iaddr;
    output [15:0] pc_inc_out;
    output flush;
    output fetch_err;

    //////////////////////
    // control signals //
    ////////////////////

    input Halt, Rtn, Exc;
    input [1:0] JType, CondOp;

    /////////////////////////
    // comparator section //
    ///////////////////////
    
    reg CmpOut;

    always @* case (CondOp)
        2'b00 : CmpOut = ~|reg1;
        2'b01 : CmpOut = |reg1;
        2'b10 : CmpOut = reg1[15];
        default : CmpOut = ~reg1[15]; // 2'b11
    endcase

    // Only flush if we are doing a branch and it's taken
    // Since we assumed that a branch would not be taken
    // Or if we're doing a jump (Like a branch that is always taken)
    assign flush = (CmpOut & (JType == 2'b11)) | (^JType) | Exc | Rtn;

    ///////////////////////////////////////
    // branch address calculation logic //
    /////////////////////////////////////

    wire [15:0] addr_base, addr_ofs, addr;

    assign addr_base = JType[1] ? pc_inc_in : reg1;
    assign addr_ofs = JType[0] ? imm : ofs;
    cla16 iBR_ADD(.A(addr_base),.B(addr_ofs),.Cin(1'b0),.Cout(),.S(addr));

    reg [15:0] pc_target;

    always @* case (JType)
        2'b00 : pc_target = pc_inc_out;
        2'b01 : pc_target = addr;
        2'b10 : pc_target = addr;
        default : pc_target = CmpOut ? addr : pc_inc_out; // 2'b11
    endcase

    ////////////////////////
    // PC & EPC register //
    //////////////////////

    wire [15:0] pc, epc;

    wire [15:0] pc_exc = Exc ? 16'h2 : (Rtn ? epc : (stall ? pc : pc_target));

    reg16 iPC (.q(pc),.d(pc_exc),.clk(clk),.en(1'b1),.rst_n(rst_n));
    reg16 iEPC (.q(epc),.d(Exc ? pc : epc),.clk(clk),.en(1'b1),.rst_n(rst_n));

    assign iaddr = pc;

    ///////////////////////////
    // pc_inc (adder) logic //
    /////////////////////////

	cla16 iADD_PC (.A(pc),.B(Halt ? 16'h0 : 16'h2),.Cin(1'b0),.Cout(),.S(pc_inc_out)); 

	// we don't consider an error case for fetch,
   	// so err is tied low.
	assign fetch_err = 1'b0;

endmodule