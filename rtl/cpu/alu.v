module alu (A, B, Op, Out, alu_err);
   
   input [15:0] A;
   input [15:0] B;
   input [3:0] Op;
   output reg [15:0] Out;
   output reg alu_err;

   wire [16:0] S;
   wire [15:0] shft;
   wire Cout;

   // Inversion logic for adder operand (used for subtract)

   wire [15:0] A_inv;
   wire inv_A;

   assign inv_A = Op[3]&Op[2];
   assign A_inv = A ^ {16{inv_A}};

   // Add 1 bit at the end so we can see the Cout result
   assign S = {1'b0, A_inv} + {1'b0, B} + {16'h0, inv_A};
   assign Cout = S[16];

   shifter iSHFT(.In(A),.Cnt(B[3:0]),.Op(Op[1:0]),.Out(shft));

   wire SEQ, SLE, SLT;
   wire Ofl;

   assign Ofl = (S[15] & ~A_inv[15] & ~B[15]) | (~S[15] & A_inv[15] & B[15]);

   assign SEQ = ~|S;
   assign SLT = SLE & ~SEQ; 
   assign SLE = (~S[15] ^ Ofl);  

   always @* casex (Op)
      4'b0000 : begin alu_err = 1'b0; Out = S[15:0]; end
      4'b0001 : begin alu_err = 1'b0; Out = {15'h0, Cout}; end
      4'b0010 : begin alu_err = 1'b0; Out = A ^ B; end
      4'b0011 : begin alu_err = 1'b0; Out = A & ~B; end
      4'b01?? : begin alu_err = 1'b0; Out = shft; end
      4'b1000 : begin alu_err = 1'b0; Out = {A[0],A[1],A[2],A[3],A[4],A[5],A[6],A[7],A[8],A[9],A[10],A[11],A[12],A[13],A[14],A[15]}; end
      4'b1001 : begin alu_err = 1'b0; Out = A; end
      4'b1010 : begin alu_err = 1'b0; Out = B; end
      4'b1011 : begin alu_err = 1'b0; Out = (A << 8) | B; end
      4'b1100 : begin alu_err = 1'b0; Out = {15'h0, SEQ}; end
      4'b1101 : begin alu_err = 1'b0; Out = {15'h0, SLT}; end
      4'b1110 : begin alu_err = 1'b0; Out = {15'h0, SLE}; end
      4'b1111 : begin alu_err = 1'b0; Out = S[15:0]; end
      default: begin  alu_err = 1'b1; Out = 16'hx; end
   endcase

    
endmodule
