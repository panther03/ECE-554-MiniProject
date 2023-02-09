module imem #(
   parameter IMEM_DEPTH = 1
) (
   input                   clk,
   input  [IMEM_DEPTH-1:0] addr_i,
   output [15:0]           inst_o
);

   localparam IMEM_ENTRIES = 1 << IMEM_DEPTH;
   
   reg [15:0] mem_r [IMEM_ENTRIES-1:0];
   reg [15:0] inst_r;

   initial begin
      $readmemh("../../out/out.hex", mem_r);
   end

   always @(negedge clk) begin
      inst_r <= mem_r[addr_i];
   end

   assign inst_o = inst_r;

endmodule