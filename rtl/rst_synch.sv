module rst_synch (
    input clk,
    input RST_n_i,
    input PLL_locked_i,
    output rst_n_o
);

// Double flip flop to synchronize RST_n signal
reg RST_n_ff1, RST_n_ff2;
always_ff @(negedge clk, negedge RST_n_i)
    if (!RST_n_i) begin
        RST_n_ff1 <= 0;
        RST_n_ff2 <= 0;
    end else begin
        RST_n_ff1 <= PLL_locked_i;
        RST_n_ff2 <= RST_n_ff1;
    end

assign rst_n_o = RST_n_ff2;
    
endmodule