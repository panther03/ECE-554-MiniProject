module dmem
import MiniLab_defs::*;
(
   input                   clk,
   input                   we_i,
   input  [DMEM_DEPTH-1:0] addr_i,
   input  [15:0]           wdata_i,
   output [15:0]           rdata_o
);

   localparam DMEM_ENTRIES = 1 << DMEM_DEPTH;

   
   reg [15:0] mem_r [DMEM_ENTRIES-1:0];
   reg [15:0] rdata_r;

   // Intel HDL Coding Styles, 14.1.7 "Simple Dual-Port, Dual-Clock Synchronous RAM"
   // We read on negative edge becuase the 552 memory reads asyncronously
   // We also write on negative edge because you have to write and read on the same edge
   always @(negedge clk) begin
      if (we_i) begin
         mem_r[addr_i] <= wdata_i;
      end
      rdata_r <= mem_r[addr_i];
   end

   assign rdata_o = rdata_r;

endmodule