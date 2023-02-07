module imem (clk, addr, inst);

   `include "mem_defs.vh"

   input                   clk;
   input  [IMEM_DEPTH-1:0] addr;
   output [15:0]           inst;
   
   reg [15:0] mem [(2**IMEM_DEPTH)-1:0];
   reg [15:0] inst_r;

   //integer i;

   initial begin
      /*for (i=0; i < (2**IMEM_DEPTH); i=i+1) begin
         mem[i] = 0;
      end*/
      $readmemh("../../out/out.hex", mem);
   end

   always @(negedge clk) begin
      inst_r <= mem[addr];
   end

   assign inst = inst_r;

endmodule