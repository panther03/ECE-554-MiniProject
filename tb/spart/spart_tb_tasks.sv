`timescale 1ns/100ps
// WHOLE MODULE ASSUMES A 50MHZ CLOCK!!
package spart_tb_tasks;

    localparam RX_WAIT = 1_000_000; // 1 million cycles as a large upper limit

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
        $display("send_uart_tx called @ time=%t", $time());
        // Just to wait for the start bit
        for (int i = 0; i <= 9; i++) begin
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
    // assumes I am starting right at the negedge of the stop bit
    task automatic recv_uart_rx(ref clk, ref RX, input int baud_int, output [7:0] rx_data);
        bit [8:0] rx_data_temp = 9'h0;
        int baud_wait = calculate_baud(baud_int) + 1;
        int baud_wait_half = (baud_wait >> 1);
        $display("baud (full/half): %d/%d", baud_wait, baud_wait_half);
        // Just to wait for the start bit
        //fork
        //    begin: wait_for_rx_negedge;
        //        @(negedge RX);
        //        disable rx_negedge_timeout;
        //    end
        //    begin: rx_negedge_timeout
        //        repeat (RX_WAIT) @(posedge clk);
        //        $display("ERR: RX never went low (start bit).");
        //        $stop();
        //    end
        //join

        $display("rx start %t", $time);
        // Advance to halfway through the transaction
        // That way we are reading the remaining bits halfway through (safer)
        repeat (baud_wait_half) @(posedge clk);
        $display("advance to half %t", $time);
        assert(RX == 0); // start bit should stay 0, this is an early sanity check

        // A UART transaction has started
        // Now we will wait the delay given by the baud rate, for each symbol
        for (int i = 0; i <= 8; i++) begin
            repeat (baud_wait) @(posedge clk);
            if (RX) begin
                rx_data_temp[i] = 1'b1;
                $display("new bit 1 %t", $time);
            end else begin
                rx_data_temp[i] = 1'b0;
                $display("new bit 0 %t", $time);
            end
        end

        // Wait for the transaction to completely end
        repeat (baud_wait_half + 1) @(posedge clk);
        $display("ending byte %t", $time);

        // Ignore stop
        rx_data = rx_data_temp[7:0];
    endtask //automatic

    task automatic assert_msg(input cond, input string msg);
        if (cond) begin
            $display("Condition passed: %s @ time = %t", msg, $time);
        end else begin
            $display("Condition failed: %s @ time = %t", msg, $time);
            $stop();
        end
    endtask

    //task automatic spart_reg_read(ref clk, ref logic [7:0] db, ref db_we, ref iocs_n, ref iorw_n, ref logic [1:0] ioaddr );
    //task automatic spart_reg_read(ref clk, ref spart_reg_bus b);
        
    //endtask //automatic
endpackage