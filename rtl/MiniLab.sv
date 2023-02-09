// WARNING - THIS CODE IS NOT WRITTEN TO STYLE
// The state machine is not coded well. I was just trying to make a POC.

module MiniLab #(
  parameter IMEM_DEPTH = 14,
  parameter DMEM_DEPTH = 13
) (
  input        CLOCK_50,
  input        RST_n,
  output       halt,
  // Peripherals
  input  [9:0] SW,
  output [9:0] LEDR,
  // UART
  input RX,
  output go
);

// This is the synchronized reset we will feed to the rest of our FPGA
wire rst_n;
rst_synch RST (
  .clk(CLOCK_50),
  .RST_n_i(RST_n),
  .rst_n_o(rst_n)
);

// Renaming clock for convenience
wire clk = CLOCK_50;

/////////////////////
// memory signals //
///////////////////

logic [15:0] iaddr;
logic [15:0] daddr;
logic [15:0] inst;
logic [15:0] data_mem_to_proc_map;
logic [15:0] data_mem_to_proc_dmem;
logic [15:0] data_proc_to_mem;

logic we_map;
logic we_dmem;

//////////////////////
// UART SM signals //
////////////////////

logic clr_rdy;
logic rdy;
logic [7:0] rx_data;
logic uart_we;
logic [15:0] insn_word;
reg [IMEM_DEPTH-1:0] iaddr_uart;
reg upper;

wire [IMEM_DEPTH-1:0] iaddr_imem = go ? iaddr[IMEM_DEPTH-1:0] : iaddr_uart;

//////////////////
// UART loader //
////////////////
UART_rx iUART_RX (
    .clk(clk),
    .rst_n(rst_n),
    .clr_rdy(clr_rdy),
    .RX(RX),
    .rx_data(rx_data),
    .rdy(rdy)
);

///////////////////////////////
// mmio peripheral signals //
////////////////////////////
logic LEDR_en;
reg [9:0] LEDR_r;

///////////////////////////////
// Processor instantiation //
////////////////////////////

proc PROC (
   // Clock and reset
   .clk(clk), .rst_n(go && rst_n),
   // Error and halt status
   .err_o(), .halt_o(halt), 
   // Instruction memory signals
   .iaddr_o(iaddr), .inst_i(inst),
   // Data memory signals
   .daddr_o(daddr), .we_o(we_map),
   .data_proc_to_mem_o(data_proc_to_mem), 
   .data_mem_to_proc_i(data_mem_to_proc_map)
);

/////////////////////////
// Instruction memory //
///////////////////////

imem #(
  .IMEM_DEPTH(IMEM_DEPTH)
) IMEM (
  .clk(clk),
  // We truncate address here but this is OK. It will just fetch 0s (HALT) if out of range
  .addr_i(iaddr_imem),
  .we_i(uart_we),
  .wdata_i(insn_word),
  .inst_o(inst)
);

//////////////////
// Data memory //
//////////////// 

dmem #(
  .DMEM_DEPTH(DMEM_DEPTH)
) DMEM (
  .clk(clk),
  .we_i(we_dmem),
  // Also OK to truncate address, we have already checked that it's in range (otherwise we would not be enabled).
  .addr_i(daddr[DMEM_DEPTH-1:0]),
  .wdata_i(data_proc_to_mem),
  .rdata_o(data_mem_to_proc_dmem)
);

///////////////////////
// Memory map logic //
/////////////////////

// Since the memory only goes up to DMEM_DEPTH-1, if any of the remaining
// upper bits are set, then we will not enable write on the memory.
assign we_dmem = (|daddr[15:DMEM_DEPTH]) ? 0 : we_map;

// Separately enable enable signal for each individual peripheral if address matches
assign LEDR_en = (we_map && (daddr==16'hC000));

// Hold LED state until the programmer writes to address again
always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
        LEDR_r <= 0;
      else if (LEDR_en)
        LEDR_r <= data_proc_to_mem[9:0];

// Handle memory mapping back to proc (we only have one peripheral but this would turn into a switch case)
assign data_mem_to_proc_map = (daddr==16'hC001) ? {6'h00 , SW} : data_mem_to_proc_dmem;

//////////////////////////
// UART insn word flop //
////////////////////////
logic inc_addr;

always_ff @(posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    insn_word <= 0;
    upper <= 0;
    uart_we <= 0;
    clr_rdy <= 0;
    inc_addr <= 0;
  end else if (~clr_rdy & rdy & upper) begin
    insn_word <= {rx_data, insn_word[7:0]};
    upper <= 0;
    uart_we <= 1;
    clr_rdy <= 1;
    inc_addr <= 1;
  end else if (~clr_rdy & rdy & ~upper) begin
    insn_word <= {insn_word[15:8], rx_data};
    upper <= 1;
    uart_we <= 0;
    clr_rdy <= 1;
    inc_addr <= 0;
  end else begin
    insn_word <= insn_word;
    upper <= upper;
    uart_we <= 0;
    clr_rdy <= 0;
    inc_addr <= 0;
  end
end

always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    iaddr_uart <= 0;
  else if (inc_addr)
    iaddr_uart <= (iaddr_uart + 14'h2);
  else
    iaddr_uart <= iaddr_uart;

always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    go <= 0;
  // magic stop word
  else if (!upper && insn_word == 16'b0000011111111111)
    go <= 1;
  else
    go <= 0;

/////////////////////
// Output signals //
///////////////////

assign LEDR = LEDR_r;
assign go_n = ~go;

endmodule