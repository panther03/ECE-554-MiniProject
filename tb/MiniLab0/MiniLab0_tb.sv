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
    $display("\nYahoo!!! All Tests Passed\n");
    $finish();
end


always
    #5 stim_clk = ~stim_clk;

endmodule

/*
To be run using the following asm file:
---------
// Load Address of LED into R0
lbi R0, 0xC0
slbi R0, 0x00

// Check with all the switches off
LD R1, R0, 0x1
BNEZ R1, .FAIL


// Wait for switch 1
NOP
NOP
.CHECK1:
NOP
LD R1, R0, 0x1
SUBI R1, R1, 0x0001
BNEZ R1, .FAIL

// Wait for switch 2
NOP
NOP
.CHECK2:
NOP
LD R1, R0, 0x1
SUBI R1, R1, 0x0002
BNEZ R1, .FAIL


// Wait for switch 3
NOP
NOP
.CHECK3:
NOP
LD R1, R0, 0x1
SUBI R1, R1, 0x0003
BNEZ R1, .FAIL


// Turn on LED 0 and wait for tb to check
LBI R1, 0x0001
ST R1, R0, 0x0
NOP
NOP
NOP
.CHECK4:
NOP

// Turn on LED 2 and wait for tb to check
LBI R1, 0x0002
ST R1, R0, 0x0
NOP
NOP
NOP
.CHECK5:
NOP

HALT

.FAIL:
J .FAIL

*/