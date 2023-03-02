module MiniLab 
import MiniLab_defs::*;
(
  input        REF_CLK,
  input        RST_n,
  output       halt,
  // Peripherals
  // Switches and LEDs
  input  [9:0] SW,
  output [9:0] LEDR,
  // UART
  input        RX,
  output       TX,
  // VGA
  output    	 VGA_BLANK_N,
  output [7:0] VGA_B,
  output       VGA_CLK,
  output [7:0] VGA_G,
  output       VGA_HS,
  output [7:0] VGA_R,
  output       VGA_SYNC_N,
  output       VGA_VS
);

// system clock from PLL
wire clk = REF_CLK;

////////////////////////////////////////////
// instantiate pll for sys clk & VGA clk //
//////////////////////////////////////////
wire pll_locked;
PLL iPLL(
  .refclk(REF_CLK),
  .rst(~RST_n),
  .outclk_0(clk),
  .outclk_1(VGA_CLK),
  .locked(pll_locked)
);

/////////////////////////
// reset synchronizer //
///////////////////////
// This is the synchronized reset we will feed to the rest of our FPGA
wire rst_n;
rst_synch RST (
  .clk(clk),
  .RST_n_i(RST_n),
  .PLL_locked_i(pll_locked),
  .rst_n_o(rst_n)
);

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
logic re_map;
logic we_dmem;

///////////////////////////////
// mmio peripheral signals //
////////////////////////////
logic LEDR_en;
reg [9:0] LEDR_r;

logic spart_iocs_n;
logic spart_iorw_n;
spart_ioaddr_t spart_ioaddr;
logic [7:0] spart_databus_in;

wire [7:0] spart_databus = (spart_iocs_n || !spart_iorw_n) ? spart_databus_in : 8'hZ;

//////////////////
// BMP signals //
////////// /////
logic x_we, y_we, cmd_we;
logic [9:0] x_pos;
logic [8:0] y_pos;
logic [7:0] cmd;


///////////////////////////////
// Processor instantiation //
////////////////////////////

proc PROC (
   // Clock and reset
   .clk(clk), .rst_n(rst_n),
   // Error and halt status
   .err_o(), .halt_o(halt), 
   // Instruction memory signals
   .iaddr_o(iaddr), .inst_i(inst),
   // Data memory signals
   .daddr_o(daddr), .we_o(we_map), .re_o(re_map),
   .data_proc_to_mem_o(data_proc_to_mem), 
   .data_mem_to_proc_i(data_mem_to_proc_map)
);

/////////////////////////
// Instruction memory //
///////////////////////

imem IMEM (
  .clk(clk),
  // We truncate address here but this is OK. It will just fetch 0s (HALT) if out of range
  .addr_i(iaddr[IMEM_DEPTH-1:0]),
  .inst_o(inst)
);

//////////////////
// Data memory //
//////////////// 

dmem DMEM (
  .clk(clk),
  .we_i(we_dmem),
  // Also OK to truncate address, we have already checked that it's in range (otherwise we would not be enabled).
  .addr_i(daddr[DMEM_DEPTH-1:0]),
  .wdata_i(data_proc_to_mem),
  .rdata_o(data_mem_to_proc_dmem)
);

// TODO: instantiate BMP display logic here

////////////////////////
// Instantiate SPART //
//////////////////////
spart SPART (
    .clk(clk),                 // 50MHz clk
    .rst_n(rst_n),             // asynch active low reset
    .iocs_n(spart_iocs_n),     // active low chip select (decode address range) 
    .iorw_n(spart_iorw_n),     // high for read, low for write 
    .tx_q_full(),              // indicates transmit queue is full       
    .rx_q_empty(),             // indicates receive queue is empty         
    .ioaddr(spart_ioaddr),     // Read/write 1 of 4 internal 8-bit registers 
    .databus(spart_databus),   // bi-directional data bus   
    .TX(TX),                   // UART TX line
    .RX(RX)                    // UART RX line
);

//////////////////////
// Instantiate BMP //
////////////////////
BMP_display BMP (
  .clk(clk),
  .rst_n(rst_n),
  .x_pos(x_pos),
  .x_we(x_we),
  .y_pos(y_pos),
  .y_we(y_we),
  .cmd_in(cmd),
  .cmd_we(cmd_we),
  .VGA_CLK(VGA_CLK),
  .status(status),
  .VGA_BLANK_N(VGA_BLANK_N),
  .VGA_HS(VGA_HS),
  .VGA_SYNC_N(VGA_SYNC_N),
  .VGA_VS(VGA_VS),
  .VGA_R(VGA_R),
  .VGA_G(VGA_G),
  .VGA_B(VGA_B),
  .idle(idle)
);

/////////////////////////
// LED register logic //
///////////////////////
// Hold LED state until the programmer writes to address again
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    LEDR_r <= 0;
  else if (LEDR_en)
    LEDR_r <= data_proc_to_mem[9:0];
	
/////////////////////////
// BMT register logic //
///////////////////////
// Hold xpos/ypos/cmd state until the programmer writes to address again
assign x_pos = data_proc_to_mem[9:0];
	
assign y_pos = data_proc_to_mem[8:0];
	
assign cmd = data_proc_to_mem[7:0];

///////////////////////
// Memory map logic //
/////////////////////

always_comb begin
  // Initialize all control signals
  // Physical memory
  we_dmem = 0;
  // LEDs/Switches
  LEDR_en = 0;
  // SPART
  spart_ioaddr = ADDR_DBUF;
  spart_iocs_n = 1'b1;
  spart_iorw_n = 1'b1;
  spart_databus_in = 8'h0;
  // BMP
  x_we = 1'b0;
  y_we = 1'b0;
  cmd_we = 1'b0;

  // Data back to processor.
  data_mem_to_proc_map = 8'h0;

  // Handle physical memory range primarily
  // Checks that none of the bits are set.
  if (~|daddr[15:DMEM_DEPTH]) begin
  
  we_dmem = we_map;
  data_mem_to_proc_map = data_mem_to_proc_dmem;

  end else begin

  // Otherwise we map to the remaining peripherals
  casez (daddr)
    // LED
    16'hC000: begin 
      if (we_map)
        LEDR_en = 1;
    end
    // Switches
    16'hC001: begin
      data_mem_to_proc_map = {6'h00 , SW};
    end
    // SPART - TX/RX buffer
    16'hC004: begin
      spart_iocs_n = ~re_map && ~we_map;
      spart_iorw_n = ~we_map;
      // databuf ioaddr is same as default
      data_mem_to_proc_map = {8'h0, spart_databus};
      spart_databus_in = data_proc_to_mem[7:0];
    end
    // SPART - Status register
    16'hC005: begin
      spart_iocs_n = ~re_map;
      spart_ioaddr = ADDR_SREG; // TODO replace with enumerated type
      data_mem_to_proc_map = {8'h0, spart_databus};
    end
    // SPART - DB register
    16'hC006, 16'hC007: begin
      spart_iocs_n = ~re_map && ~we_map;
      spart_iorw_n = ~we_map;
      spart_ioaddr = daddr[0] ? ADDR_DBH : ADDR_DBL; 
      data_mem_to_proc_map = {8'h0, spart_databus};
      spart_databus_in = data_proc_to_mem[7:0];
    end
	// BMP - X pos
	16'hC008: begin
	  x_we = we_map;
	end
	// BMP - Y pos
	16'hC009: begin
	  y_we = we_map;
	end
	// BMP - cmd
	16'hC00A: begin
	  cmd_we = we_map;
	end
	// BMP - status reg
	16'hC00B: begin
	  data_mem_to_proc_map = {15'h00 , idle};
	end
    // TODO: Add memory mapped logic in this case statement
    // There is no default because all of our inputs
    // are defaulted. It would be the same thing.
  endcase

  end
end

/////////////////////
// Output signals //
///////////////////
assign LEDR = LEDR_r;

endmodule