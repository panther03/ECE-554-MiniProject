module shifter (In, Cnt, Op, Out);
   
   input [15:0] In;
   input [3:0]  Cnt;
   input [1:0]  Op;
   output [15:0] Out;

   wire [15:0] sr1_out,sr2_out,sr3_out;
   reg [15:0] sr0_in,sr1_in,sr2_in,sr3_in;

   // 00 => ROL
   // 01 => SLL
   // 10 => ROR
   // 11 => SRL

   always @* case (Op)
      2'b00 : sr3_in = {In[7:0],In[15:8]};
      2'b01 : sr3_in = {In[7:0],8'h0};
      2'b10 : sr3_in = {In[7:0],In[15:8]};
      2'b11 : sr3_in = {8'h0,In[15:8]};
   endcase

   always @* case (Op)
      2'b00 : sr2_in = {sr3_out[11:0],sr3_out[15:12]};
      2'b01 : sr2_in = {sr3_out[11:0],4'b0000};
      2'b10 : sr2_in = {sr3_out[3:0],sr3_out[15:4]};
      2'b11 : sr2_in = {4'b0000,sr3_out[15:4]};
   endcase

   always @* case (Op)
      2'b00 : sr1_in = {sr2_out[13:0],sr2_out[15:14]};
      2'b01 : sr1_in = {sr2_out[13:0],2'b00};
      2'b10 : sr1_in = {sr2_out[1:0],sr2_out[15:2]};
      2'b11 : sr1_in = {2'b00,sr2_out[15:2]};
   endcase

   always @* case (Op)
      2'b00 : sr0_in = {sr1_out[14:0],sr1_out[15]};
      2'b01 : sr0_in = {sr1_out[14:0],1'b0};
      2'b10 : sr0_in = {sr1_out[0],sr1_out[15:1]};
      2'b11 : sr0_in = {1'b0,sr1_out[15:1]};
   endcase
   
   assign sr3_out = Cnt[3] ? sr3_in : In;
   assign sr2_out = Cnt[2] ? sr2_in : sr3_out;
   assign sr1_out = Cnt[1] ? sr1_in : sr2_out;
   assign Out = Cnt[0] ? sr0_in : sr1_out;

endmodule

