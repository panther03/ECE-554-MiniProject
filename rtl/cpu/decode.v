module decode (inst, write_in, reg1, reg2, imm, ofs,
               InstFmt, JType, XtendSel, RegWrite,
               bypass_reg1, bypass_reg2, writesel,
               decode_err, clk, rst_n);

    input clk, rst_n;

    input [15:0] inst, write_in;
    input [2:0] writesel;
    input bypass_reg1, bypass_reg2;
    output [15:0] reg1, reg2, imm, ofs;
    output decode_err;

    //////////////////////
    // control signals //
    ////////////////////

    input [1:0] InstFmt, JType;
    input XtendSel, RegWrite;

    ///////////////
    // rf logic //
    /////////////

    wire [2:0] reg1sel, reg2sel;
    wire [15:0] reg1raw, reg2raw;

    assign reg1sel = inst[10:8];
    assign reg2sel = inst[7:5];

    rf iRF (.clk(clk),.rst_n(rst_n),.write(RegWrite),.err(decode_err),
            .read1regsel(reg1sel),.read2regsel(reg2sel),.writeregsel(writesel),
            .read1data(reg1raw),.read2data(reg2raw),.writedata(write_in));

    assign reg1 = bypass_reg1 ? write_in : reg1raw;
    assign reg2 = bypass_reg2 ? write_in : reg2raw;

    /////////////////////////////
    // immediate decode logic //
    ///////////////////////////

    wire [15:0] imm_sign_extend,imm_zero_extend;

    assign imm_sign_extend = InstFmt[0] ? {{11{inst[4]}},inst[4:0]} : {{8{inst[7]}},inst[7:0]};
    assign imm_zero_extend = InstFmt[0] ? {11'h0,inst[4:0]} : {8'h0,inst[7:0]};

    assign imm = XtendSel ? imm_zero_extend : imm_sign_extend;

    // sign extend for branch offset
    assign ofs = {{5{inst[10]}},inst[10:0]};
    
endmodule