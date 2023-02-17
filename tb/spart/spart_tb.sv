// To be run with fw/MiniLab0.asm

`timescale 1ns/100ps
module spart_tb ();

import spart_tb_tasks::*;

// TODO move these to a package in the RTL. we should agree on what the addresses are
localparam ADDR_DBUF = 2'b00;
localparam ADDR_SREG = 2'b01;
localparam ADDR_DBL  = 2'b10;
localparam ADDR_DBH  = 2'b11;

localparam QUEUE_SIZE = 8;
localparam STIM_QUEUE_SIZE = QUEUE_SIZE + (QUEUE_SIZE >> 1);

interface spart_reg_bus (input clk);
    logic iocs_n;
    logic iorw_n;
    logic [1:0] ioaddr;
    logic [7:0] databus_out;

    semaphore databus_lock = new (1);

    wire [7:0] databus = (iocs_n || !srb.iorw_n) ? databus_out : 8'hZ;

    task automatic spart_reg_write (input logic [1:0] addr, input logic [7:0] wdata);
        databus_lock.get(1);
        iocs_n = 0;
        iorw_n = 0;
        ioaddr = addr;
        databus_out = wdata;
        @(posedge clk);
        iocs_n = 1;
        iorw_n = 1;
        databus_lock.put(1);
    endtask

    task automatic spart_reg_read (input logic [1:0] addr, output logic [7:0] rdata);
        databus_lock.get(1);
        iocs_n = 0;
        iorw_n = 1;
        ioaddr = addr;
        rdata = databus;
        @(posedge clk);
        iocs_n = 1;
        iorw_n = 1;
        databus_lock.put(1);
    endtask
endinterface //spart_reg_bus

reg clk;
reg rst_n;

//reg iocs_n;
//reg iorw_n;

wire tx_q_full;
wire rx_q_empty;

//reg [1:0] ioaddr;
//reg [7:0] stim_databus;
spart_reg_bus srb(.clk(clk));


logic spart_rx;
logic spart_tx;

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

// Neither of these values are initialized, this is fine as we kind of want them to be X so the tests are meaningful
// This value stores the value we got from a register read on the SPART bus.
reg [7:0] srb_reg_temp;
// so we can use both high & low
reg [7:0] db_high_temp;

reg [7:0] uart_rx_temp;

reg tx_fifo_half_full;
reg rx_fifo_half_full;

reg [7:0] tx_fifo_stim [STIM_QUEUE_SIZE-1:0];
reg [7:0] rx_fifo_stim [STIM_QUEUE_SIZE-1:0];

// we use this one when filling or emptying the fifos
// not trying to do that concurrently so we do not need separate variables
integer both_fifo_ind;

// we inrcement this one over the course of the uart reads and writes
integer tx_fifo_ind;
integer rx_fifo_ind;

initial begin;
    // Initialize signals
    clk = 0;
    rst_n = 0;
    spart_rx = 1;

    srb.databus_out = 8'h0;
    srb.iocs_n = 1;
    srb.iorw_n = 1;
    srb.ioaddr = 2'h0;

    both_fifo_ind = 0;
    tx_fifo_ind = 0;
    rx_fifo_ind = 0;

    tx_fifo_half_full = 0;
    rx_fifo_half_full = 0;

    // Initialize our stimulation data
    for (both_fifo_ind = 0; both_fifo_ind < STIM_QUEUE_SIZE; both_fifo_ind++) begin
        tx_fifo_stim[both_fifo_ind] = $rand();
        rx_fifo_stim[both_fifo_ind] = $rand();
    end

    // Deassert reset
    @(negedge clk);
    rst_n = 1;

    // Test 1: RX Queue and TX queue both start out empty.
    srb.spart_reg_read(ADDR_SREG, srb_reg_temp);
    assert(srb_reg_temp == 8'h00);
    assert(!tx_q_full);
    assert(rx_q_empty);
    
    // Test 2: Baud rate defaults to 115200
    srb.spart_reg_read(ADDR_DBH, db_high_temp);
    srb.spart_reg_read(ADDR_DBL, srb_reg_temp);
    assert(calculate_baud_bd({db_high_temp[4:0],srb_reg_temp}) == 115200);

    fork
        begin: FILL_TX_FIFO
            for (both_fifo_ind = 0; both_fifo_ind < QUEUE_SIZE; both_fifo_ind++) begin
                srb.spart_reg_write(ADDR_DBUF, tx_fifo_stim[both_fifo_ind]);
                srb.spart_reg_read(ADDR_SREG, srb_reg_temp);
                assert(srb_reg_temp[7:4] == QUEUE_SIZE-both_fifo_ind-1);
            end 
            assert(tx_q_full);
            forever begin: stall_till_half_full
                if (tx_fifo_half_full)
                    disable stall_till_half_full;
            end
            for (both_fifo_ind = QUEUE_SIZE; both_fifo_ind < STIM_QUEUE_SIZE; both_fifo_ind++) begin
                srb.spart_reg_write(ADDR_DBUF, tx_fifo_stim[both_fifo_ind]);
                srb.spart_reg_read(ADDR_SREG, srb_reg_temp);
                assert(srb_reg_temp[7:4] == STIM_QUEUE_SIZE-both_fifo_ind-1);
            end
            assert(tx_q_full);
        end
        begin: READ_TX_FROM_SPART
            for (tx_fifo_ind = 0; tx_fifo_ind < STIM_QUEUE_SIZE; tx_fifo_ind++) begin
                recv_uart_rx(clk, spart_tx, 115200, uart_rx_temp);
                assert(uart_rx_temp == tx_fifo_stim[tx_fifo_ind]);
                srb.spart_reg_read(ADDR_SREG, srb_reg_temp);
                if (srb_reg_temp[7:4])
                assert(srb_reg_temp[7:4] == tx_fifo_ind+1);
                if (srb_reg_temp[7:4] == QUEUE_SIZE << 1)
                    tx_fifo_half_full = 1'b1;
            end
        end
        // begin: WRITE_RX_TO_SPART
        //     repeat (50) @(posedge clk); // delay a little to avoid reg reads colliding
        //     for (rx_fifo_ind = 0; rx_fifo_ind < QUEUE_SIZE; rx_fifo_ind++) begin
        //         send_uart_tx(clk, spart_rx, 115200, rx_fifo_stim[rx_fifo_ind]);
        //         srb.spart_reg_read(ADDR_SREG, srb_reg_temp);
        //         assert(srb_reg_temp[3:0] == rx_fifo_ind+1);
        //         assert(!rx_q_empty);
        //     end
        // end
    join

    // The RX queue should be full. we will from it and check it.
    // for (both_fifo_ind = 0; both_fifo_ind < QUEUE_SIZE; both_fifo_ind++) begin
    //     srb.spart_reg_write(ADDR_DBUF, tx_fifo_stim[both_fifo_ind]);
    //     srb.spart_reg_read(ADDR_SREG, srb_reg_temp);
    //     assert(srb_reg_temp[7:4] == QUEUE_SIZE-both_fifo_ind-1);
    // end
    // assert(tx_q_full);
    
    /*// Test 3: Interleaved reads/writes
    fork
        begin: tx
            @(posedge clk); // delay TX by one cycle so RX can see negedge
            send_uart_tx(clk, TX_RX, 19200, 8'h5A);
        end
        begin: rx
            recv_uart_rx(clk, TX_RX, 19200, tx_data);
        end
    join*/

    $display("\nYahoo!!! All Tests Passed\n");
    $finish();
end


always
    #10 clk = ~clk;

endmodule