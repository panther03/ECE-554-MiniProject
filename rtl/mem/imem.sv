module imem #(
   parameter IMEM_DEPTH = 1
) (
   input                   clk,
   input  [IMEM_DEPTH-1:0] addr_i,
   input                   we_i,
   input  [15:0]           wdata_i,
   output [15:0]           inst_o
);

   localparam IMEM_ENTRIES = 1 << IMEM_DEPTH;
   
   reg [15:0] mem_r [IMEM_ENTRIES-1:0];
   reg [15:0] inst_r;

   always @(negedge clk) begin
      if (we_i) begin
         mem_r[addr_i] <= wdata_i;
      end
      inst_r <= mem_r[addr_i];
   end

   assign inst_o = inst_r;

endmodule