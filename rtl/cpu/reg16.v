module reg16 (q,d,en,clk,rst_n);

    output [15:0] q;
    input [15:0] d;
    input clk;
    input rst_n;
    input en;

    wire [15:0] d_with_en;

    assign d_with_en = en ? d : q;

    dff iFFx16[15:0] (.q(q),.d(d_with_en),.clk(clk),.rst_n(rst_n));
    
endmodule