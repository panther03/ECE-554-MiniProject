module MiniLab0 #(
  parameter IMEM_DEPTH = 14,
  parameter DMEM_DEPTH = 13
) (CLOCK_50, RST_n, LEDR_out, SW_in, halt);

input CLOCK_50;
input RST_n;

input [9:0] SW_in;
output reg [9:0] LEDR_out;

wire rst_n;
rst_synch RST (
  .clk(CLOCK_50),
  .RST_n(RST_n),
  .rst_n(rst_n)
);

wire clk = CLOCK_50;



output halt;

logic [15:0] iaddr;
logic [15:0] daddr;
logic [15:0] inst;
logic [15:0] data_mem_to_proc_map;
logic [15:0] data_mem_to_proc_dmem;
logic [15:0] data_proc_to_mem;

logic we_map;
logic we_dmem;

logic LEDR_en;

// Processor instantiation
proc PROC (
   // Error signal
   .err(), 
   // Halt signal
   .halt(halt),
   // Clock and reset
   .clk(clk), .rst_n(rst_n),
   // Instruction memory signals
   .iaddr(iaddr), .inst(inst),
   // Data memory signals
   .daddr(daddr), .we(we_map),
   .data_proc_to_mem(data_proc_to_mem), 
   .data_mem_to_proc(data_mem_to_proc_map)
);

// Instruction memory
imem #(
  .IMEM_DEPTH(IMEM_DEPTH)
) IMEM (
  .clk(clk),
  .addr(iaddr[IMEM_DEPTH-1:0]),
  .inst(inst)
);

// Data memory
dmem #(
  .DMEM_DEPTH(DMEM_DEPTH)
) DMEM (
  .clk(clk),
  .we(we_dmem),
  .addr(daddr[DMEM_DEPTH-1:0]),
  .data_in(data_proc_to_mem),
  .data_out(data_mem_to_proc_dmem)
);

///////////////////////
// Memory map logic //
/////////////////////

assign we_dmem = (|daddr[15:DMEM_DEPTH]) ? 0 : we_map;

assign LEDR_en = (we_map && (daddr==16'hC000));
always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
        LEDR_out <= 0;
      else if (LEDR_en)
        LEDR_out <= data_proc_to_mem[9:0];

assign data_mem_to_proc_map = (daddr==16'hC001) ? {6'h00 , SW_in} : data_mem_to_proc_dmem;

endmodule