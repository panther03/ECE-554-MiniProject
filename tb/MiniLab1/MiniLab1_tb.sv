// To be run with fw/HelloWorld.asm

`timescale 1ns/100ps
module MiniLab1_tb ();

import spart_tb_tasks::*;

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

    wait (iDUT.iaddr == 16'h005c);
    repeat (5000) @(posedge stim_clk);
    send_uart_tx(stim_clk, stim_RX, 115200, 8'h4A);
    repeat (5000) @(posedge stim_clk);
    send_uart_tx(stim_clk, stim_RX, 115200, 8'h55);
    repeat (5000) @(posedge stim_clk);
    send_uart_tx(stim_clk, stim_RX, 115200, 8'h4C);
    repeat (5000) @(posedge stim_clk);
    send_uart_tx(stim_clk, stim_RX, 115200, 8'h49);
    repeat (5000) @(posedge stim_clk);
    send_uart_tx(stim_clk, stim_RX, 115200, 8'h45);
    repeat (5000) @(posedge stim_clk);
    send_uart_tx(stim_clk, stim_RX, 115200, 8'h4E);
    repeat (5000) @(posedge stim_clk);
    send_uart_tx(stim_clk, stim_RX, 115200, 8'h0D);
    wait (iDUT.iaddr == 16'h00DC);
    repeat (3000) @(posedge stim_clk);
    $display("\nYahoo!!! All Tests Passed\n");
    $finish();
end


always
    #10 stim_clk = ~stim_clk;

endmodule