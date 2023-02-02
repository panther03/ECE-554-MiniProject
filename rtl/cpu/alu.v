module alu (A, B, Op, Out, alu_err);
   
   input [15:0] A;
   input [15:0] B;
   input [3:0] Op;
   output reg [15:0] Out;
   output reg alu_err;

   wire [15:0] S, shft;
   wire Cout;

   // Inversion logic for adder operand (used for subtract)

   wire [15:0] A_inv;
   wire inv_A;

   assign inv_A = Op[3]&Op[2];
   assign A_inv = A ^ {16{inv_A}};


   cla16 iCLA16(.A(A_inv),.B(B),.Cin(inv_A),.Cout(Cout),.S(S));

   shifter iSHFT(.In(A),.Cnt(B[3:0]),.Op(Op[1:0]),.Out(shft));

   wire SEQ, SLE, SLT;
   wire Ofl;

   assign Ofl = (S[15] & ~A_inv[15] & ~B[15]) | (~S[15] & A_inv[15] & B[15]);

   assign SEQ = ~|S;
   assign SLT = SLE & ~SEQ; 
   assign SLE = (~S[15] ^ Ofl);  

   always @* casex (Op)
      4'b0000 : begin alu_err = 1'b0; Out = S; end
      4'b0001 : begin alu_err = 1'b0; Out = Cout; end
      4'b0010 : begin alu_err = 1'b0; Out = A ^ B; end
      4'b0011 : begin alu_err = 1'b0; Out = A & ~B; end
      4'b01?? : begin alu_err = 1'b0; Out = shft; end
      4'b1000 : begin alu_err = 1'b0; Out = {A[0],A[1],A[2],A[3],A[4],A[5],A[6],A[7],A[8],A[9],A[10],A[11],A[12],A[13],A[14],A[15]}; end
      4'b1001 : begin alu_err = 1'b0; Out = A; end
      4'b1010 : begin alu_err = 1'b0; Out = B; end
      4'b1011 : begin alu_err = 1'b0; Out = (A << 8) | B; end
      4'b1100 : begin alu_err = 1'b0; Out = SEQ; end
      4'b1101 : begin alu_err = 1'b0; Out = SLT; end
      4'b1110 : begin alu_err = 1'b0; Out = SLE; end
      4'b1111 : begin alu_err = 1'b0; Out = S; end
      default: begin  alu_err = 1'b1; Out = 15'hx; end
   endcase

    
endmodule
