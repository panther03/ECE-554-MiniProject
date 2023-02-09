module dmem #(
   parameter DMEM_DEPTH = 1
) (clk, we, addr, data_in, data_out);

   input                   clk;
   input                   we;
   input  [DMEM_DEPTH-1:0] addr;
   input  [15:0]           data_in;
   output [15:0]           data_out;

   localparam DMEM_ENTRIES = 1 << DMEM_DEPTH;

   
   reg [15:0] mem [DMEM_ENTRIES-1:0];
   reg [15:0] data_out_r;

   // Don't need an initial block because Altera says BRAM is
   // always initialized to 0 at power-up
   /*integer i;

   initial begin
      for (i=0; i < DMEM_ENTRIES; i=i+1) begin
         mem[i] = 0;
      end
   end*/

   // Intel HDL Coding Styles, 14.1.7 "Simple Dual-Port, Dual-Clock Synchronous RAM"

   always @(negedge clk) begin
      if (we) begin
         mem[addr] = data_in;
      end
      data_out_r <= mem[addr];
   end

   assign data_out = data_out_r;

endmodule