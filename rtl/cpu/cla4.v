module cla4 (A,B,Cin,S,PG,GG);
    input [3:0] A,B;
    input Cin;
    output [3:0] S;
    output PG,GG;
    
    wire [3:0] P,G;
    wire [3:0] C;

    assign C[0] = Cin;

    // individual carry/propogate adders
    cpa iCPAx4[3:0] (.A(A),.B(B),.Cin(C),.S(S),.P(P),.G(G));
    
    // carry look ahead block
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & C[1]);
    assign C[3] = G[2] | (P[2] & C[2]);

    // group propogate & generate
    assign PG = &P;
    assign GG = G[3] | (G[2] & P[3]) | (G[1] & P[3] & P[2]) | (G[0] & P[3] & P[2] & P[1]);
endmodule