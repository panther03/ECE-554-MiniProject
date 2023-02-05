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

   always @(posedge clk) begin
      if (en)
         if (wr)
            mem[addr] <= data_in;
         data_out_r <= mem[addr];
   end

   assign data_out = data_out_r;

endmodule