// To be run with fw/MiniLab1.asm

`timescale 1ns/100ps
module MiniLab1_tb ();

logic stim_clk;
logic stim_rst_n;

logic [9:0] stim_sw;
logic [9:0] led_out;

logic halt;

logic stim_TX;
logic stim_RX;

MiniLab iDUT (
    .clk(stim_clk),
    .RST_n(stim_rst_n),
    .halt(halt),
    .SW(stim_sw),
    .LEDR(led_out),
    .RX(stim_RX),
    .TX(stim_TX)
);

initial begin;
    // Initialize signals
    stim_clk = 0;
    stim_rst_n = 0;
    stim_sw = 10'h000;
    stim_RX = 1'b1;

    // Deassert reset
    @(negedge stim_clk);
    stim_rst_n = 1;

    fork
        begin: run_tests
            // Wait till processor halts.
            @(posedge halt);
            disable halt_timeout;
        end
        begin: halt_timeout;
            repeat (1000) @(posedge stim_clk);
            disable run_tests;
            $display("Timed out waiting for processor's halt signal..");
            $stop();
        end
    join
    $display("\nYahoo!!! All Tests Passed\n");
    $finish();
end


always
    #5 stim_clk = ~stim_clk;

endmodule