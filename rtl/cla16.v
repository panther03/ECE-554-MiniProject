module cla16 (A,B,Cin,Cout,S);
    input [15:0] A,B;
    input Cin;
    output Cout;
    output [15:0] S;
    
    wire [3:0] P,G;
    wire [3:0] C;

    assign C[0] = Cin;

    // individual 4-bit CLA adders
    cla4 iCLA4x4[3:0] (.A(A),.B(B),.Cin(C),.S(S),.PG(P),.GG(G));
    
    // carry look ahead block
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & C[1]);
    assign C[3] = G[2] | (P[2] & C[2]);
    assign Cout = G[3] | (P[3] & C[3]);

endmodule