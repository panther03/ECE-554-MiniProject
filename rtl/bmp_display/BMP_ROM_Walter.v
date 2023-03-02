module BMP_ROM_Walter(clk,addr,dout);

input clk;				// 50MHz clock
input [15:0] addr;
output reg [8:0] dout;	// pixel out

  reg [8:0] rom[0:13249];
  
  initial
    $readmemh("rsmall.hex",rom);
  
  always @(posedge clk)
    dout <= rom[addr];

endmodule
