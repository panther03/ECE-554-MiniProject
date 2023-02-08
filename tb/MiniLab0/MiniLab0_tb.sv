module MiniLab0_tb ();

logic stim_clk;
logic stim_rst_n;

logic [9:0] stim_sw;
logic [9:0] led_out;


MiniLab0 iDUT (.CLOCK_50(stim_clk), .RST_n(stim_rst_n), .LEDR_out(led_out), .SW_in(stim_sw), .halt(halt));


initial begin;

    // Start test bench
    stim_clk = 0;
    stim_rst_n = 0;
    stim_sw = 10'h000;

    @(negedge stim_clk);
    stim_rst_n = 1;

    fork
        begin: run_tests

            wait (iDUT.iaddr == 16'h000c); // Wait until the the processor is ready to check for switch 1
            $display("Instruction 0x000c");
            $display("Turning on Switch 1");
            stim_sw = 10'h001;

            wait (iDUT.iaddr == 16'h0018); // Wait until the the processor is ready to check for switch 2
            $display("Instruction 0x0018");
            $display("Turning on Switch 2");
            stim_sw = 10'h002;

            wait (iDUT.iaddr == 16'h0024); // Wait until the the processor is ready to check for switch 3
            $display("Instruction 0x0024");
            $display("Turning on Switch 3");
            stim_sw = 10'h003;

            wait (iDUT.iaddr == 16'h0036); // Wait until after the processor has turned on LED 1
            $display("Instruction 0x0036");
            if (led_out == 10'h001)
                $display("LED 1 is on");
            else begin
                $display("ERROR: LED 1 is off");
                $stop();
            end

            wait (iDUT.iaddr == 16'h0042); // Wait until after the processor has turned on LED 2
            $display("Instruction 0x00342");
            if (led_out == 10'h002)
                $display("LED 2 is on");
            else begin
                $display("ERROR: LED 2 is off");
                $stop();
            end

            
            @(posedge halt);
            disable halt_timeout;
        end
        begin: halt_timeout;
            repeat (1000) @(posedge stim_clk);
            disable run_tests;
            $display("Timed out waiting for processor's halt signal..");
            $display("This could mean a switch was not set and the processor timed out while waiting for it");
            $stop();
        end
    join
    $display("Yahoo, All Tests Passed");
    $finish();
end


always
    #5 stim_clk = ~stim_clk;

endmodule