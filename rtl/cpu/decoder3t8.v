module decoder3t8 (
    adr, sel_bits
);

input [2:0] adr;
output reg [7:0] sel_bits;

always @* case (adr)
    3'b000 : sel_bits = 8'b00000001;
    3'b001 : sel_bits = 8'b00000010;
    3'b010 : sel_bits = 8'b00000100;
    3'b011 : sel_bits = 8'b00001000;
    3'b100 : sel_bits = 8'b00010000;
    3'b101 : sel_bits = 8'b00100000;
    3'b110 : sel_bits = 8'b01000000;
    3'b111 : sel_bits = 8'b10000000;
    default : sel_bits = 8'b00000000;
endcase

endmodule