module reg16 (q,d,en,clk,rst_n);

    output reg [15:0] q;
    input [15:0] d;
    input clk;
    input rst_n;
    input en;

    always @(posedge clk, negedge rst_n) 
        if (!rst_n)
            q <= 0;
        else if (en)
            q <= d;
    
endmodule