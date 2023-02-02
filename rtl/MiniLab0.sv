module MiniLab0(clk, rst_n, LEDR_out, SW_in);

input clk;
input rst_n;

input [9:0] SW_in;
output reg [9:0] LEDR_out;

logic [15:0] iaddr;
logic [15:0] daddr;
logic [15:0] inst;
logic [15:0] data_mem_to_proc_unchecked;
logic [15:0] data_mem_to_proc_checked;
logic [15:0] data_proc_to_mem;

logic wr_unchecked;
logic wr_checked;
logic en;

logic LEDR_en;

proc PROC (
   // Error signal
   .err(), 
   // Clock and reset
   .clk(clk), .rst_n(rst_n),
   // Instruction memory signals
   .iaddr(iaddr), .inst(inst),
   // Data memory signals
   .daddr(daddr), .wr(wr_unchecked), .en(en), .data_in(data_proc_to_mem), .data_out(data_mem_to_proc_checked)
   );


assign wr_checked = (daddr==16'hCXXX) ? 0 : wr_unchecked;

assign LEDR_en = (wr_unchecked && (daddr==16'hC000));
always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
        LEDR_out <= 0;
      else if (LEDR_en)
        LEDR_out <= data_proc_to_mem[9:0];

assign data_mem_to_proc_checked = (daddr==16'hC001) ? {6'h00 , SW_in} : data_mem_to_proc_unchecked;


// Instruction memory
imem IMEM (.clk(clk), .addr(iaddr), .inst(inst));

// Data memory
dmem DMEM (.clk(clk), .wr(wr_unchecked), .en(en), .addr(daddr), .data_in(data_proc_to_mem), .data_out(data_mem_to_proc_unchecked));

endmodule