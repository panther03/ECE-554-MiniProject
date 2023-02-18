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
    logic [7:0] rx_data;


    logic [7:0] status_reg;


    logic [7:0] databus_in;
    logic [7:0] databus_out;
    assign databus = (!iocs_n & iorw_n) ? databus_out : 16'hZZZZ;
    assign databus_in = databus;

    logic [12:0]DB;
    always_ff @(posedge clk,negedge rst_n)
    if (!rst_n) 
        DB <= 0;
    else if (ioaddr == 2'b10 && ~iorw_n) begin
        DB[7:0] <= databus_in;
        DB[12:8] <= DB[12:8];
    end else if (ioaddr == 2'b11 && ~iorw_n) begin
        DB[7:0] <= DB[7:0];
        DB[12:8] <= databus_in[4:0];
    end else
        DB <= DB;


    UART_rx uart_rx (
    .clk(clk), .rst_n(rst_n), // input
    .clr_rdy(1'b0), // input
    .RX(RX), // input
    .rx_data(rx_data), // output
    .rdy(new_data_ready) // output
    );


    UART_tx uart_tx (
    .clk(clk), .rst_n(rst_n), // input
    .trmt(transmit), // input
    .tx_data(tx_data), // input
    .tx_done(tx_done), // output
    .TX(TX) // output
    );


    
    logic [3:0] tx_old_ptr;
    logic [3:0] tx_new_ptr;
    logic [7:0] tx_queue_in;
    logic tx_queue_write;
    queue tx_queue (.clk(clk), .enable(tx_queue_write), .raddr(tx_old_ptr[2:0]), .waddr(tx_new_ptr[2:0]), .wdata(tx_queue_in), .rdata(tx_data));
    
always_ff @(posedge clk,negedge rst_n)
    if (!rst_n) begin
        tx_new_ptr <= 1'b0;
        tx_queue_write = 0;
    end else if (~iocs_n && ioaddr == 2'b00 && ~iorw_n) begin
        tx_new_ptr <= tx_new_ptr + 1;
        tx_queue_write = 1;
    end else begin
        tx_old_ptr <= tx_old_ptr; 
        tx_queue_write = 0;
    end


always_ff @(posedge clk,negedge rst_n)
    if (!rst_n) begin
        tx_old_ptr <= 1'b0;
        transmit = 0;
    end else if (tx_done && status_reg[7:4] != 8) begin
        tx_old_ptr <= tx_old_ptr + 1;
        transmit = 1;
    end else begin
        tx_old_ptr <= tx_old_ptr; 
        transmit = 0;
    end



    logic [3:0] rx_old_ptr;
    logic [3:0] rx_new_ptr;
    logic [7:0] rx_queue_out;
    logic rx_queue_write;
    queue rx_queue (.clk(clk), .enable(rx_queue_write), .raddr(tx_old_ptr[2:0]), .waddr(tx_new_ptr[2:0]), .wdata(rx_data), .rdata(rx_queue_out));

    always_ff @(posedge clk,negedge rst_n)
        if (!rst_n) begin
            rx_new_ptr <= 1'b0;
        end else if(~iocs_n && ioaddr == 2'b00 && iorw_n) begin
            rx_new_ptr <= rx_new_ptr + 1;
        end else begin
            rx_new_ptr <= rx_new_ptr;
        end


    assign rx_queue_write = new_data_ready;

    always_ff @(posedge clk,negedge rst_n)
        if (!rst_n) begin
            rx_old_ptr <= 1'b0;
        end else if (new_data_ready && status_reg[3:0] != 8) begin
            rx_old_ptr <= rx_old_ptr + 1;
        end else begin
            rx_old_ptr <= rx_old_ptr; 
        end

    assign tx_q_full = (tx_old_ptr[2:0] == tx_new_ptr[2:0] && tx_old_ptr != tx_new_ptr);
    assign rx_q_empty = (rx_old_ptr[2:0] == rx_new_ptr[2:0] && rx_old_ptr == rx_new_ptr);


    assign status_reg[7:4] = tx_q_full ? 0 : tx_new_ptr[2:0] - tx_old_ptr[2:0]; // Number of entries remaining in tx queue
    assign status_reg[3:0] = rx_q_empty ? 0 : 8 - rx_new_ptr[2:0] - rx_old_ptr[2:0]; // Number of entries filled in rq queue

				   
endmodule
