// To be run with fw/MiniLab0.asm

`timescale 1ns/100ps
module spart_tb ();

import spart_tb_tasks::*;

reg clk;
reg rst_n;

reg iocs_n;
reg iorw_n;

wire tx_q_full;
wire tx_q_empty;

reg [1:0] ioaddr;
reg databus_we;
reg [7:0] stim_databus;
wire [7:0] databus = databus_we ? stim_databus : 1'hZ;

reg TX_RX;

reg [7:0] tx_data;

/*spart iDUT (
    .clk(clk),                 // 50MHz clk
    .rst_n(rst_n),             // asynch active low reset
    .iocs_n(iocs_n),           // active low chip select (decode address range) 
    .iorw_n(iorw_n),           // high for read, low for write 
    .tx_q_full(tx_q_full),     // indicates transmit queue is full       
    .rx_q_empty(rx_q_empty),   // indicates receive queue is empty         
    .ioaddr(ioaddr),           // Read/write 1 of 4 internal 8-bit registers 
    .databus(databus),         // bi-directional data bus   
    .TX(TX),                   // UART TX line
    .RX(RX)                    // UART RX line
);*/

initial begin;
    // Initialize signals
    clk = 0;
    rst_n = 0;
    TX_RX = 1;
    
    databus_we = 0;
    iocs_n = 1;
    iorw_n = 1;

    // Deassert reset
    @(negedge clk);
    rst_n = 1;

    
    fork
        begin: tx
            @(posedge clk); // delay TX by one cycle so RX can see negedge
            send_uart_tx(clk, TX_RX, 19200, 8'h5A);
        end
        begin: rx
            recv_uart_rx(clk, TX_RX, 19200, tx_data);
        end
    join
    $display(tx_data);
    $display("\nYahoo!!! All Tests Passed\n");
    $finish();
end


always
    #10 clk = ~clk;

endmodule