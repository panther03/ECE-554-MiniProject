module rst_synch (
    input clk,
    input RST_n,
    output rst_n
);

reg RST_n_ff1, RST_n_ff2;
always_ff @(negedge clk, negedge RST_n)
    if (!RST_n) begin
        RST_n_ff1 <= 0;
        RST_n_ff2 <= 0;
    end else begin
        RST_n_ff1 <= 1'b1;
        RST_n_ff2 <= RST_n_ff1;
    end

assign rst_n = RST_n_ff2;
    
endmodule