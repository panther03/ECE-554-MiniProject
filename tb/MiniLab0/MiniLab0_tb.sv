module MiniLab0_tb ();

logic stim_clk;
logic stim_rst_n;

MiniLab0 DUT (.clk(stim_clk), .rst_n(stim_rst_n), .LEDR_out(), .SW_in());


initial begin;
    // Start test bench
    stim_clk = 0;
    stim_rst_n = 0;

    #10 stim_rst_n = 1;

    

    #10000 $stop();
end


always
    #5 stim_clk = ~stim_clk;

endmodule