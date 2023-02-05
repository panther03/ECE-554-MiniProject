module MiniLab0_tb ();

logic stim_clk;
logic stim_rst_n;

logic [9:0] stim_sw;
logic [9:0] led_out;

MiniLab0 iDUT (.CLOCK_50(stim_clk), .RST_n(stim_rst_n), .LEDR_out(led_out), .SW_in(stim_sw));


initial begin;
    // Start test bench
    stim_clk = 0;
    stim_rst_n = 0;
    stim_sw = 10'h1AA;

    @(negedge stim_clk);
    stim_rst_n = 1;

    fork
        begin: wait_for_halt
            @(posedge iDUT.PROC.MEM_WB_ctrl_Halt_out);
        end
        begin
            repeat (1000) @(posedge stim_clk);
            disable wait_for_halt;
            $display("Timed out waiting for processor's halt signal..");
            $stop();
        end
    join

    $finish();
end


always
    #5 stim_clk = ~stim_clk;

endmodule