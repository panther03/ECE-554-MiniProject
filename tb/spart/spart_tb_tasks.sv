`timescale 1ns/100ps
package spart_tb_tasks;

    localparam RX_WAIT = 1_000_000; // 1 million cycles as a large upper limit

    function bit [12:0] calculate_baud(input int baud_int);
        return $floor((50_000_000)/baud_int);
    endfunction

    // we are sending TO TX, not receiving TX from the other end
    task automatic send_uart_tx(ref clk, ref TX, input int baud_int, input [7:0] tx_data);
        int baud_wait = calculate_baud(baud_int);
        bit [9:0] tx_data_temp = {1'b0, tx_data, 1'b1}; // start and stop
        // Just to wait for the start bit
        for (int i = 9; i >= 0; i--) begin
            if (tx_data_temp[i]) begin
                $display("Setting TX = 1 @ %t", $time());
                TX = 1;
            end else begin
                $display("Setting TX = 0 @ %t", $time());
                TX = 0;
            end
            repeat (baud_wait) @(posedge clk);
        end
    endtask //automatic

    // we are reading from RX, not sending to RX on the other end
    task automatic recv_uart_rx(ref clk, ref RX, input int baud_int, output [7:0] rx_data);
        bit [8:0] rx_data_temp = 9'h0;
        int baud_wait = calculate_baud(baud_int);
        // Just to wait for the start bit
        fork
            begin: wait_for_rx_negedge;
                @(negedge RX);
                disable rx_negedge_timeout;
            end
            begin: rx_negedge_timeout
                repeat (RX_WAIT) @(posedge clk);
                $display("ERR: RX never went low (start bit).");
                $stop();
            end
        join

        // Advance to halfway through the transaction
        // That way we are reading the remaining bits halfway through (safer)
        repeat (baud_wait >> 1) @(posedge clk);
        assert(RX == 0); // start bit should stay 0, this is an early sanity check

        // A UART transaction has started
        // Now we will wait the delay given by the baud rate, for each symbol
        fork
            begin: rx_timeout
                // 10 because we have 8 bits + the remainder of a start and a stop
                $display("Start waiting: %t", $time());
                repeat (10 * baud_wait) @(posedge clk);
                $display("ERR: RX transaction did not complete in time. %t", $time());
                $stop();
            end
            begin: rx
                for (int i = 0; i <= 8; i++) begin
                    repeat (baud_wait) @(posedge clk);
                    if (RX) begin
                        rx_data_temp[i] = 1'b1;
                    end else begin
                        rx_data_temp[i] = 1'b0;
                    end
                end
                disable rx_timeout;
            end
        join
        rx_data = rx_data_temp[7:0];
    endtask //automatic
endpackage