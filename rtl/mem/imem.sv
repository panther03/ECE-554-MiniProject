module imem #(
   parameter IMEM_DEPTH = 1
) (clk, addr, inst);

   input                   clk;
   input  [IMEM_DEPTH-1:0] addr;
   output [15:0]           inst;

   localparam IMEM_ENTRIES = 1 << IMEM_DEPTH;
   
   reg [15:0] mem [IMEM_ENTRIES-1:0];
   reg [15:0] inst_r;

   //integer i;

   initial begin
      /*for (i=0; i < (IMEM_ENTRIES); i=i+1) begin
         mem[i] = 0;
      end*/
      $readmemh("../../out/out.hex", mem);
   end

   always @(negedge clk) begin
      inst_r <= mem[addr];
   end

   assign inst = inst_r;

endmodule