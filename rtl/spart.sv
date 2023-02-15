//////////////////////////////////////////////////////////////////////////////////
// Engineer: Elan Graupe and Julian 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
// Project Name: 
// Target Devices: DE1_SOC board
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spart(
    input clk,				// 50MHz clk
    input rst_n,			// asynch active low reset
    input iocs_n,			// active low chip select (decode address range)
    input iorw_n,			// high for read, low for write
    output tx_q_full,		// indicates transmit queue is full
    output rx_q_empty,		// indicates receive queue is empty
    input [1:0] ioaddr,		// Read/write 1 of 4 internal 8-bit registers
    inout [7:0] databus,	// bi-directional data bus
    output TX,				// UART TX line
    input RX				// UART RX line
    );


    logic [7:0] tx_data;
    logic transmit;
    logic tx_done;

    logic new_data_ready;
    logic clr_rdy;
    logic [7:0] rx_data;

    UART_rx (
    .clk(clk), .rst_n(rst_n), // input
    .clr_rdy(clr_rdy), // input
    .RX(RX), // input
    .rx_data(rx_data), // output
    .rdy(new_data_ready) // output
    );


    UART_tx (
    .clk(clk), .rst_n(rst_n), // input
    .trmt(transmit), // input
    .tx_data(tx_data), // input
    .tx_done(tx_done), // output
    .TX(TX) // output
    );


    
    logic [3:0] tx_old_ptr;
    logic [3:0] tx_new_ptr;
    logic [7:0] tx_queue_in;
    queue tx_queue (.clk(clk), .enable(), .raddr(tx_old_ptr[2:0]), .waddr(tx_new_ptr[2:0]), .wdata(tx_queue_in), .rdata(tx_data));
    
    always_ff @(posedge clk,negedge rst_n)
    if (!rst_n) begin
        tx_old_ptr <= 1'b0;
        tx_new_ptr <= 1'b0;
    end else if (ioaddr == 1'b00 && iorw_n) begin
        tx_new_ptr <= tx_new_ptr + 1;
        tx_old_ptr <= tx_old_ptr;
    end else if () begin
        tx_new_ptr <= tx_new_ptr;
        tx_old_ptr <= tx_old_ptr + 1;
    end else begin
        tx_old_ptr <= tx_old_ptr; 
        tx_new_ptr <= tx_new_ptr;
    end



    logic [3:0] rx_old_ptr;
    logic [3:0] rx_new_ptr;
    logic [7:0] rx_queue_out;
    queue rx_queue (.clk(clk), .enable(), .raddr(tx_old_ptr[2:0]), .waddr(tx_new_ptr[2:0]), .wdata(rx_data), .rdata(rx_queue_out));

    always_ff @(posedge clk,negedge rst_n)
    if (!rst_n) begin
        tx_old_ptr <= 1'b0;
        tx_new_ptr <= 1'b0;
    end else if () begin
        rx_new_ptr <= rx_new_ptr + 1;
        rx_old_ptr <= rx_old_ptr;
    end else if(ioaddr == 1'b00 && ~iorw_n) begin
        rx_new_ptr <= rx_new_ptr;
        rx_old_ptr <= rx_old_ptr + 1;
    end else begin
        tx_old_ptr <= tx_old_ptr; 
        tx_new_ptr <= tx_new_ptr;
    end

    assign tx_q_full = (tx_old_ptr[2:0] == tx_new_ptr[2:0] && tx_old_ptr != tx_new_ptr)
    assign rx_q_empty = (rx_old_ptr[2:0] == rx_new_ptr[2:0] && rx_old_ptr == rx_new_ptr)


    logic [7:0] status_reg;
    assign status_reg[7:4] = 0; // Number of entries remaining
    assign status_reg[3:0] = 0; // Number of entries available



    


				   
endmodule
