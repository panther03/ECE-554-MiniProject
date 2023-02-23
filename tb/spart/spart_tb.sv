`timescale 1ns/100ps
module spart_tb ();

import MiniLab_defs::*;
import spart_tb_tasks::*;

localparam QUEUE_SIZE = 8;
localparam STIM_QUEUE_SIZE = QUEUE_SIZE + (QUEUE_SIZE >> 1);
localparam TX_STIM_QUEUE_SIZE = STIM_QUEUE_SIZE + 2; // +2 because we can hold one more entry in the tx_data before the queue is actually full, and we do this two times

interface spart_reg_bus (input clk);
    logic iocs_n;
    logic iorw_n;
    logic [1:0] ioaddr;
    logic [7:0] databus_out;

    wire [7:0] databus = (iocs_n || !iorw_n) ? databus_out : 8'hZ;

    task automatic spart_reg_write (input logic [1:0] addr, input logic [7:0] wdata);
        iocs_n = 0;
        iorw_n = 0;
        ioaddr = addr;
        databus_out = wdata;
        @(posedge clk);
        iocs_n = 1;
        iorw_n = 1;
    endtask

    task automatic spart_reg_read (input logic [1:0] addr, output logic [7:0] rdata);
        iocs_n = 0;
        iorw_n = 1;
        ioaddr = addr;
        @(posedge clk);
        rdata = databus;
        iocs_n = 1;
        iorw_n = 1;
    endtask
endinterface //spart_reg_bus

reg clk;
reg rst_n;

wire tx_q_full;
wire rx_q_empty;

spart_reg_bus srb(.clk(clk));

logic spart_rx;
logic spart_tx;

spart iDUT (
    .clk(clk),                 // 50MHz clk
    .rst_n(rst_n),             // asynch active low reset
    .iocs_n(srb.iocs_n),       // active low chip select (decode address range) 
    .iorw_n(srb.iorw_n),       // high for read, low for write 
    .tx_q_full(tx_q_full),     // indicates transmit queue is full       
    .rx_q_empty(rx_q_empty),   // indicates receive queue is empty         
    .ioaddr(srb.ioaddr),       // Read/write 1 of 4 internal 8-bit registers 
    .databus(srb.databus),     // bi-directional data bus   
    .TX(spart_tx),             // UART TX line
    .RX(spart_rx)              // UART RX line
);

// Neither of these values are initialized, this is fine as we kind of want them to be X so the tests are meaningful
// This value stores the value we got from a register read on the SPART bus.
reg [7:0] srb_reg_temp;
// store the whole databuffer so we can also have high & low
reg [16:0] db_temp;

reg [7:0] uart_rx_temp;
reg new_uart_rx_data;

reg tx_fifo_half_full;
reg rx_fifo_half_full;

// array to hold our stimulus data to fill the queue with
reg [7:0] tx_fifo_stim [TX_STIM_QUEUE_SIZE-1:0];
reg [7:0] rx_fifo_stim [STIM_QUEUE_SIZE-1:0];

// we use these when filling or emptying the fifos
integer tx_fill_fifo_ind;
integer rx_empty_fifo_ind; 

// we increment these over the course of the uart reads and writes
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

    tx_fifo_ind = 0;
    rx_fifo_ind = 0;

    tx_fill_fifo_ind = 0;
    rx_empty_fifo_ind = 0;

    tx_fifo_half_full = 0;
    rx_fifo_half_full = 0;

    uart_rx_temp = 0;
    new_uart_rx_data = 0;

    // Initialize our stimulation data
    for (tx_fill_fifo_ind = 0; tx_fill_fifo_ind < TX_STIM_QUEUE_SIZE; tx_fill_fifo_ind++) begin
        tx_fifo_stim[tx_fill_fifo_ind] = $random;
    end
    for (rx_empty_fifo_ind = 0; rx_empty_fifo_ind < STIM_QUEUE_SIZE; rx_empty_fifo_ind++) begin
        rx_fifo_stim[rx_empty_fifo_ind] = $random;
    end

    // Deassert reset
    @(negedge clk);
    rst_n = 1;
    
    @(posedge clk);
    /////////////////////////////////////////////////////////
    // Test 1: RX Queue and TX queue both start out empty //
    ///////////////////////////////////////////////////////
    srb.spart_reg_read(ADDR_SREG, srb_reg_temp);
    assert_msg(srb_reg_temp == 8'h80, "Status register defaults to 80");
    assert_msg(!tx_q_full, "TX queue defaults to not full");
    assert_msg(rx_q_empty, "RX queue defaults to empty");
    
    ///////////////////////////////////////////
    // Test 2: Baud rate defaults to 115200 //
    /////////////////////////////////////////
    srb.spart_reg_read(ADDR_DBH, db_temp[15:8]);
    srb.spart_reg_read(ADDR_DBL, db_temp[7:0]);
    assert_msg(calculate_baud(115200) == db_temp[12:0], "Baud rate defaults to 115200");
    
    /////////////////////////////////////////////////
    // Test 3: Verify we can write to DB register //
    ///////////////////////////////////////////////
    // Set baud rate to 19200
    db_temp = calculate_baud(19200);
    srb.spart_reg_write(ADDR_DBH, db_temp[15:8]);
    srb.spart_reg_write(ADDR_DBL, db_temp[7:0]);
    db_temp = 0;

    // Check new baud rate
    srb.spart_reg_read(ADDR_DBH, db_temp[15:8]);
    srb.spart_reg_read(ADDR_DBL, db_temp[7:0]);
    assert_msg(calculate_baud(19200) == db_temp[12:0], "Baud rate set to 19200");

    ///////////////////////////////////////
    // Test 4: Interleaved reads/writes //
    /////////////////////////////////////
    fork
        begin: FILL_TX_FIFO
            for (tx_fill_fifo_ind = 0; tx_fill_fifo_ind <= QUEUE_SIZE; tx_fill_fifo_ind++) begin
                srb.spart_reg_write(ADDR_DBUF, tx_fifo_stim[tx_fill_fifo_ind]);
                srb.spart_reg_read(ADDR_SREG, srb_reg_temp);
                // conditional is there because once we've written the first queue entry, old pointer advances
                // this is to be expected, as soon as TX consumes the data we should increment the old 
                // point because the data has been consumed (TODO: check with eric?)
                assert_msg(srb_reg_temp[7:4] == QUEUE_SIZE-tx_fill_fifo_ind+((tx_fill_fifo_ind > 0) ? 0 : -1), "Status register (TX) increases with filling queue");
            end 
            assert_msg(tx_q_full, "Full signal asserted when queue is filled");

            wait(tx_fifo_half_full);

            for (tx_fill_fifo_ind = QUEUE_SIZE+1; tx_fill_fifo_ind < TX_STIM_QUEUE_SIZE; tx_fill_fifo_ind++) begin
                srb.spart_reg_write(ADDR_DBUF, tx_fifo_stim[tx_fill_fifo_ind]);
                srb.spart_reg_read(ADDR_SREG, srb_reg_temp);
                assert_msg(srb_reg_temp[7:4] == TX_STIM_QUEUE_SIZE-tx_fill_fifo_ind-1, "Status register (TX) tracks while re-filling TX queue");
            end
            assert_msg(tx_q_full, "Full signal asserted when queue is re-filled");
        end
        begin: READ_TX_FROM_SPART
            for (tx_fifo_ind = 0; tx_fifo_ind < TX_STIM_QUEUE_SIZE; tx_fifo_ind++) begin
                wait(new_uart_rx_data);
                new_uart_rx_data = 0;
                assert_msg(uart_rx_temp == tx_fifo_stim[tx_fifo_ind], "Transmitted TX data matches queue data");
                @(posedge clk);
                srb.spart_reg_read(ADDR_SREG, srb_reg_temp);
                
                if (tx_fifo_ind <= QUEUE_SIZE >> 1) begin
                    assert_msg(srb_reg_temp[7:4] == tx_fifo_ind, "Status register (TX) tracks after transmitting entry");
                end else begin
                    // math is because we re-filled it to half
                    assert_msg(srb_reg_temp[7:4] == (tx_fifo_ind - (QUEUE_SIZE >> 1) - 1), "Status register (TX) tracks after transmitting entry from re-filled queue");
                end

                if (tx_fifo_ind == QUEUE_SIZE >> 1)
                    // trigger the re-fill
                    tx_fifo_half_full = 1'b1;
            end
        end
        begin: WRITE_RX_TO_SPART
            repeat (100) @(posedge clk); // delay a little to avoid reg reads colliding
            for (rx_fifo_ind = 0; rx_fifo_ind < STIM_QUEUE_SIZE; rx_fifo_ind++) begin
                send_uart_tx(clk, spart_rx, 19200, rx_fifo_stim[rx_fifo_ind]);
                srb.spart_reg_read(ADDR_SREG, srb_reg_temp);
                if (rx_fifo_ind < QUEUE_SIZE >> 1) begin
                    assert_msg(srb_reg_temp[3:0] == rx_fifo_ind+1, "Status register (RX) tracks after sending UART data");
                end else begin
                    // math is because we emptied it
                    assert_msg(srb_reg_temp[3:0] == (rx_fifo_ind+1 - (QUEUE_SIZE >> 1)), "Status register (TX) tracks after transmitting entry from re-filled queue");
                end
                assert_msg(!rx_q_empty, "Empty signal is not high while data in RX queue");
                if (rx_fifo_ind+1 == QUEUE_SIZE >> 1)
                    rx_fifo_half_full = 1'b1;
            end
        end
        begin: EMPTY_RX_FIFO_HALFWAY
            wait(rx_fifo_half_full);
            // half full signal has been triggered. we're going to empty what's in there and let it be refilled.
            for (rx_empty_fifo_ind = 0; rx_empty_fifo_ind < (QUEUE_SIZE >> 1); rx_empty_fifo_ind++) begin
                srb.spart_reg_read(ADDR_DBUF, srb_reg_temp);
                assert_msg(srb_reg_temp == rx_fifo_stim[rx_empty_fifo_ind], "Received RX data matches queue data"); // todo better error messsage because thats not realy what we're testing
                srb.spart_reg_read(ADDR_SREG, srb_reg_temp);
                assert_msg(srb_reg_temp[3:0] == (QUEUE_SIZE>>1)-rx_empty_fifo_ind-1, "Status register (RX) tracks after reading RX fifo");
            end
        end
    join

    // TX FIFO should be totally empty, and RX FIFO should be completely full
    // Now we empty the RX FIFO and make sure the data is correct
    for (rx_empty_fifo_ind = (QUEUE_SIZE >> 1); rx_empty_fifo_ind < STIM_QUEUE_SIZE; rx_empty_fifo_ind++) begin
        srb.spart_reg_read(ADDR_DBUF, srb_reg_temp);
        assert_msg(srb_reg_temp == rx_fifo_stim[rx_empty_fifo_ind], "Received RX data matches queue data"); // todo better error messsage because thats not realy what we're testing
        srb.spart_reg_read(ADDR_SREG, srb_reg_temp);
        assert_msg(srb_reg_temp[3:0] == (STIM_QUEUE_SIZE)-rx_empty_fifo_ind-1, "Status register (RX) tracks after reading RX fifo");
    end

    // The RX queue should be full. we will from it and check it.
    // for (both_fifo_ind = 0; both_fifo_ind < QUEUE_SIZE; both_fifo_ind++) begin
    //     srb.spart_reg_write(ADDR_DBUF, tx_fifo_stim[both_fifo_ind]);
    //     srb.spart_reg_read(ADDR_SREG, srb_reg_temp);
    //     assert(srb_reg_temp[7:4] == QUEUE_SIZE-both_fifo_ind-1);
    // end
    // assert(tx_q_full);
    

    $display("\nYahoo!!! All Tests Passed\n");
    $finish();
end

// This essentially acts as our simulated version of a UART
// Wait for RX to go low (start bit)
always @(negedge spart_tx) begin
    $display("Starting a receive at %t..", $time);
    recv_uart_rx(clk, spart_tx, 19200, uart_rx_temp);
    new_uart_rx_data = 1;
end


always
    #10 clk = ~clk;

endmodule