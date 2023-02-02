module control (op_word, ctrl_err,
                RegWrite, MemWrite, MemRead, InstFmt,
                MemToReg, AluSrc, AluOp, CondOp,
                JType, XtendSel, Exc, Rtn, Halt);

    // 7 bit opcode word comprised of the 5-bit opcode,
    // and the 2 LSBs of the instruction to indicate ALU
    // operation in the R-type case (in that order.)
    input [6:0] op_word;
    output reg ctrl_err;
    output reg [3:0] AluOp;
    output reg [1:0] InstFmt, JType, CondOp;
    output reg RegWrite, MemWrite, MemRead,
        MemToReg, AluSrc, XtendSel, Exc, Rtn, Halt;

    always @* casex (op_word)
        7'b00000_??: begin RegWrite = 0; MemWrite = 0; MemRead = 0; InstFmt = 2'b00; MemToReg = 0; AluSrc = 0; AluOp = 4'b0000; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 1; ctrl_err = 0; end // HALT
        7'b00001_??: begin RegWrite = 0; MemWrite = 0; MemRead = 0; InstFmt = 2'b00; MemToReg = 0; AluSrc = 0; AluOp = 4'b0000; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // NOP
        7'b01000_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b01; MemToReg = 0; AluSrc = 1; AluOp = 4'b0000; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // ADDI
        7'b01001_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b01; MemToReg = 0; AluSrc = 1; AluOp = 4'b1111; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // SUBI
        7'b01010_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b01; MemToReg = 0; AluSrc = 1; AluOp = 4'b0010; CondOp = 2'b00; JType = 2'b00; XtendSel = 1; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // XORI
        7'b01011_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b01; MemToReg = 0; AluSrc = 1; AluOp = 4'b0011; CondOp = 2'b00; JType = 2'b00; XtendSel = 1; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // ANDNI
        7'b10100_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b01; MemToReg = 0; AluSrc = 1; AluOp = 4'b0100; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // ROLI
        7'b10101_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b01; MemToReg = 0; AluSrc = 1; AluOp = 4'b0101; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // SLLI
        7'b10110_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b01; MemToReg = 0; AluSrc = 1; AluOp = 4'b0110; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // RORI
        7'b10111_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b01; MemToReg = 0; AluSrc = 1; AluOp = 4'b0111; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // SRLI
        7'b10000_??: begin RegWrite = 0; MemWrite = 1; MemRead = 0; InstFmt = 2'b01; MemToReg = 0; AluSrc = 1; AluOp = 4'b0000; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // ST
        7'b10001_??: begin RegWrite = 1; MemWrite = 0; MemRead = 1; InstFmt = 2'b01; MemToReg = 1; AluSrc = 1; AluOp = 4'b0000; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // LD
        7'b10011_??: begin RegWrite = 1; MemWrite = 1; MemRead = 0; InstFmt = 2'b01; MemToReg = 0; AluSrc = 1; AluOp = 4'b0000; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // STU
        7'b11001_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b10; MemToReg = 0; AluSrc = 0; AluOp = 4'b1000; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // BTR
        7'b11011_00: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b10; MemToReg = 0; AluSrc = 0; AluOp = 4'b0000; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // ADD
        7'b11011_01: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b10; MemToReg = 0; AluSrc = 0; AluOp = 4'b1111; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // SUB
        7'b11011_10: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b10; MemToReg = 0; AluSrc = 0; AluOp = 4'b0010; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // XOR
        7'b11011_11: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b10; MemToReg = 0; AluSrc = 0; AluOp = 4'b0011; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // ANDN
        7'b11010_00: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b10; MemToReg = 0; AluSrc = 0; AluOp = 4'b0100; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // ROL
        7'b11010_01: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b10; MemToReg = 0; AluSrc = 0; AluOp = 4'b0101; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // SLL
        7'b11010_10: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b10; MemToReg = 0; AluSrc = 0; AluOp = 4'b0110; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // ROR
        7'b11010_11: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b10; MemToReg = 0; AluSrc = 0; AluOp = 4'b0111; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // SRL
        7'b11100_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b10; MemToReg = 0; AluSrc = 0; AluOp = 4'b1100; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // SEQ
        7'b11101_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b10; MemToReg = 0; AluSrc = 0; AluOp = 4'b1101; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // SLT
        7'b11110_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b10; MemToReg = 0; AluSrc = 0; AluOp = 4'b1110; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // SLE
        7'b11111_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b10; MemToReg = 0; AluSrc = 0; AluOp = 4'b0001; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // SCO
        7'b01100_??: begin RegWrite = 0; MemWrite = 0; MemRead = 0; InstFmt = 2'b00; MemToReg = 0; AluSrc = 0; AluOp = 4'b0000; CondOp = 2'b00; JType = 2'b11; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // BEQZ
        7'b01101_??: begin RegWrite = 0; MemWrite = 0; MemRead = 0; InstFmt = 2'b00; MemToReg = 0; AluSrc = 0; AluOp = 4'b0000; CondOp = 2'b01; JType = 2'b11; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // BNEZ
        7'b01110_??: begin RegWrite = 0; MemWrite = 0; MemRead = 0; InstFmt = 2'b00; MemToReg = 0; AluSrc = 0; AluOp = 4'b0000; CondOp = 2'b10; JType = 2'b11; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // BLTZ
        7'b01111_??: begin RegWrite = 0; MemWrite = 0; MemRead = 0; InstFmt = 2'b00; MemToReg = 0; AluSrc = 0; AluOp = 4'b0000; CondOp = 2'b11; JType = 2'b11; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // BGEZ
        7'b11000_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b00; MemToReg = 0; AluSrc = 1; AluOp = 4'b1010; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // LBI
        7'b10010_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b00; MemToReg = 0; AluSrc = 1; AluOp = 4'b1011; CondOp = 2'b00; JType = 2'b00; XtendSel = 1; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // SLBI
        7'b00100_??: begin RegWrite = 0; MemWrite = 0; MemRead = 0; InstFmt = 2'b11; MemToReg = 0; AluSrc = 0; AluOp = 4'b0000; CondOp = 2'b00; JType = 2'b10; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // J
        7'b00101_??: begin RegWrite = 0; MemWrite = 0; MemRead = 0; InstFmt = 2'b00; MemToReg = 0; AluSrc = 0; AluOp = 4'b0000; CondOp = 2'b00; JType = 2'b01; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // JR
        7'b00110_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b11; MemToReg = 0; AluSrc = 0; AluOp = 4'b1001; CondOp = 2'b00; JType = 2'b10; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // JAL
        7'b00111_??: begin RegWrite = 1; MemWrite = 0; MemRead = 0; InstFmt = 2'b00; MemToReg = 0; AluSrc = 0; AluOp = 4'b1001; CondOp = 2'b00; JType = 2'b01; XtendSel = 0; Exc = 0; Rtn = 0; Halt = 0; ctrl_err = 0; end // JALR
        7'b00010_??: begin RegWrite = 0; MemWrite = 0; MemRead = 0; InstFmt = 2'b00; MemToReg = 0; AluSrc = 0; AluOp = 4'b0000; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 1; Rtn = 0; Halt = 0; ctrl_err = 0; end // siic
        7'b00011_??: begin RegWrite = 0; MemWrite = 0; MemRead = 0; InstFmt = 2'b00; MemToReg = 0; AluSrc = 0; AluOp = 4'b0000; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 0; Rtn = 1; Halt = 0; ctrl_err = 0; end // rti
        default: begin RegWrite = 0; MemWrite = 0; MemRead = 0; InstFmt = 2'b00; MemToReg = 0; AluSrc = 0; AluOp = 4'b0000; CondOp = 2'b00; JType = 2'b00; XtendSel = 0; Exc = 1; Halt = 0; ctrl_err = 1; end // error case (default)
    endcase
endmodule