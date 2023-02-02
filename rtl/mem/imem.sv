module imem (clk, addr, inst);

   `include "mem_defs.vh"

   input                   clk;
   input  [IMEM_DEPTH-1:0] addr;
   output [15:0]           inst;
   
   reg [15:0] mem [(2**IMEM_DEPTH)-1:0];
   reg [15:0] inst_r;

   initial begin
      $readmemh("../../out/out.hex", mem);
   end

   always @(posedge clk) begin
      inst_r <= mem[addr];
   end

   assign inst = inst_r;

endmodule