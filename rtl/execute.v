module execute (reg1, reg2, imm, pc_inc, alu_out,
                AluOp, JType, InstFmt, AluSrc,
                ex_err); 

    input [15:0] reg1, reg2, imm, pc_inc;
    output [15:0] alu_out;
    output ex_err;

    //////////////////////
    // control signals //
    ////////////////////

    input [3:0] AluOp;
    input [1:0] JType, InstFmt;
    input AluSrc;

    ///////////////////////
    // main ALU section //
    /////////////////////

    wire [15:0] aluA, aluB;
    wire alu_err;

    assign aluA = ^JType ? pc_inc : reg1;
    assign aluB = AluSrc ? imm : reg2;
    alu iALU(.A(aluA),.B(aluB),.Op(AluOp),.Out(alu_out),.alu_err(alu_err));

    // Error handling
    assign ex_err = alu_err;

endmodule