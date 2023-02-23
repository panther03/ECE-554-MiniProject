`timescale 1ns/100ps
// WHOLE MODULE ASSUMES A 50MHZ CLOCK!!
package spart_tb_tasks;
    // Uncomment this if you want UART debugging messages
    //`define UART_DEBUGGING

    // This function takes in an integer corresponding to a UART baud rate
    // and spits out the value that you would load into the databuffer register for that baud rate
    // NOTE: when you are using this value to actually read from our UART, you need to add +1
    // Our UART_TX/RX design needs an extra clock cycle to load the data, THEN count up to zero
    function bit [12:0] calculate_baud(input int baud_int);
        return $floor((50_000_000)/baud_int);
    endfunction

    // we are sending TO TX, not receiving TX from the other end
    task automatic send_uart_tx(ref clk, ref TX, input int baud_int, input [7:0] tx_data);
        int baud_wait = calculate_baud(baud_int) + 1;
        bit [9:0] tx_data_temp = {1'b1, tx_data, 1'b0}; // start and stop
        `ifdef UART_DEBUGGING $display("send_uart_tx called @ time=%t", $time()); `endif
        for (int i = 0; i <= 9; i++) begin
            if (tx_data_temp[i]) begin
                `ifdef UART_DEBUGGING $display("Setting TX = 1 @ %t", $time()); `endif
                TX = 1;
            end else begin
                `ifdef UART_DEBUGGING $display("Setting TX = 0 @ %t", $time()); `endif
                TX = 0;
            end
            repeat (baud_wait) @(posedge clk);
        end
    endtask //automatic

    // we are reading from RX, not sending to RX on the other end
    // assumes I am starting right at the negedge of the stop bit
    task automatic recv_uart_rx(ref clk, ref RX, input int baud_int, output [7:0] rx_data);
        bit [8:0] rx_data_temp = 9'h0;
        int baud_wait = calculate_baud(baud_int) + 1;
        int baud_wait_half = (baud_wait >> 1);
        `ifdef UART_DEBUGGING $display("baud (full/half): %d/%d", baud_wait, baud_wait_half); `endif

        `ifdef UART_DEBUGGING $display("rx start %t", $time); `endif
        // Advance to halfway through the transaction
        // That way we are reading the remaining bits halfway through (safer)
        repeat (baud_wait_half) @(posedge clk);
        `ifdef UART_DEBUGGING $display("advance to half %t", $time); `endif
        assert(RX == 0); // start bit should stay 0, this is an early sanity check

        // A UART transaction has started
        // Now we will wait the delay given by the baud rate, for each symbol
        for (int i = 0; i <= 8; i++) begin
            repeat (baud_wait) @(posedge clk);
            if (RX) begin
                rx_data_temp[i] = 1'b1;
                `ifdef UART_DEBUGGING $display("new bit 1 %t", $time); `endif
            end else begin
                rx_data_temp[i] = 1'b0;
                `ifdef UART_DEBUGGING $display("new bit 0 %t", $time); `endif
            end
        end

        // Wait for the transaction to completely end
        repeat (baud_wait_half + 1) @(posedge clk);
        `ifdef UART_DEBUGGING $display("ending byte %t", $time); `endif

        // Ignore stop
        rx_data = rx_data_temp[7:0];
    endtask

endpackage