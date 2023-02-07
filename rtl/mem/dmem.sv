module dmem (clk, wr, en, addr, data_in, data_out);

   `include "mem_defs.vh"

   input                   clk;
   input                   wr;
   input                   en;
   input  [DMEM_DEPTH-1:0] addr;
   input  [15:0]           data_in;
   output [15:0]           data_out;

   
   reg [15:0] mem [(2**DMEM_DEPTH)-1:0];
   reg [15:0] data_out_r;

   // Don't need an initial block because Altera says BRAM is
   // always initialized to 0 at power-up
   /*integer i;

   initial begin
      for (i=0; i < (2**DMEM_DEPTH); i=i+1) begin
         mem[i] = 0;
      end
   end*/

   always @(negedge clk) begin
      if (en) begin
         if (wr)
            mem[addr] <= data_in;
         data_out_r <= mem[addr];
      end else begin
         data_out_r <= 0;
      end
   end

   assign data_out = data_out_r;

endmodule