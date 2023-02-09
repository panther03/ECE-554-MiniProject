module UARTLoading_tb ();

logic stim_clk;
logic stim_rst_n;

logic [9:0] stim_sw;
logic [9:0] led_out;

logic RX;

MiniLab iDUT (.CLOCK_50(stim_clk), .RST_n(stim_rst_n), .LEDR(led_out), .SW(stim_sw), .halt(halt), .RX(RX), .go());


initial begin;
    // Start test bench
    stim_clk = 0;
    stim_rst_n = 0;
    stim_sw = 10'h1AA;
    RX = 1;

    @(negedge stim_clk);
    stim_rst_n = 1;

    repeat (50) @(posedge stim_clk);

    repeat (8) begin
        // START
        #52083 RX = 0;
        // DATA
        #52083 RX = 1;
        #52083 RX = 0;
        #52083 RX = 1;
        #52083 RX = 0;
        #52083 RX = 1;
        #52083 RX = 0;
        #52083 RX = 1;
        #52083 RX = 0;
        // STOP
        #52083 RX = 1;

        repeat (50) @(posedge stim_clk);

        // START
        #52083 RX = 0;
        // DATA
        #52083 RX = 0;
        #52083 RX = 1;
        #52083 RX = 0;
        #52083 RX = 1;
        #52083 RX = 0;
        #52083 RX = 1;
        #52083 RX = 0;
        #52083 RX = 0;
        // STOP
        #52083 RX = 1;

        repeat (50) @(posedge stim_clk);
    end

    // START
    #52083 RX = 0;
    // DATA
    #52083 RX = 1;
    #52083 RX = 1;
    #52083 RX = 1;
    #52083 RX = 1;
    #52083 RX = 1;
    #52083 RX = 1;
    #52083 RX = 1;
    #52083 RX = 1;
    // STOP
    #52083 RX = 1;

    repeat (50) @(posedge stim_clk);

    // START
    #52083 RX = 0;
    // DATA
    #52083 RX = 1;
    #52083 RX = 1;
    #52083 RX = 1;
    #52083 RX = 0;
    #52083 RX = 0;
    #52083 RX = 0;
    #52083 RX = 0;
    #52083 RX = 0;
    // STOP
    #52083 RX = 1;

    repeat (50) @(posedge stim_clk);
    
    $display("YAHOO! Test passed.");
    $finish();
end


always
    #10 stim_clk = ~stim_clk;

endmodule