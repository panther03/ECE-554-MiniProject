module dmem #(
   parameter DMEM_DEPTH = 1
) (
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
   always @(negedge clk) begin
      if (we_i) begin
         mem_r[addr_i] <= wdata_i;
      end
      rdata_r <= mem_r[addr_i];
   end

   assign rdata_o = rdata_r;

endmodule