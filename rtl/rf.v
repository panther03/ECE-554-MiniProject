/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module rf (
           // Outputs
           read1data, read2data, err,
           // Inputs
           clk, rst, read1regsel, read2regsel, writeregsel, writedata, write
           );
   input clk, rst;
   input [2:0] read1regsel;
   input [2:0] read2regsel;
   input [2:0] writeregsel;
   input [15:0] writedata;
   input        write;

   output reg [15:0] read1data;
   output reg [15:0] read2data;
   output err;

   // your code
   wire [15:0] reg0out,reg1out,reg2out,reg3out,reg4out,reg5out,reg6out,reg7out;
   reg [15:0] reg0in,reg1in,reg2in,reg3in,reg4in,reg5in,reg6in,reg7in;

   wire [7:0] write_sel;

   // Enable selection logic for write port. Decodes 3-bit select signal to
   // 8 enable signals, which is then piped to each register.

   decoder3t8 iDEC (.adr(writeregsel),.sel_bits(write_sel));

   reg16 iREG0 (.q(reg0out),.d(reg0in),.clk(clk),.en(write_sel[0] & write),.rst(rst));
   reg16 iREG1 (.q(reg1out),.d(reg1in),.clk(clk),.en(write_sel[1] & write),.rst(rst));
   reg16 iREG2 (.q(reg2out),.d(reg2in),.clk(clk),.en(write_sel[2] & write),.rst(rst));
   reg16 iREG3 (.q(reg3out),.d(reg3in),.clk(clk),.en(write_sel[3] & write),.rst(rst));
   reg16 iREG4 (.q(reg4out),.d(reg4in),.clk(clk),.en(write_sel[4] & write),.rst(rst));
   reg16 iREG5 (.q(reg5out),.d(reg5in),.clk(clk),.en(write_sel[5] & write),.rst(rst));
   reg16 iREG6 (.q(reg6out),.d(reg6in),.clk(clk),.en(write_sel[6] & write),.rst(rst));
   reg16 iREG7 (.q(reg7out),.d(reg7in),.clk(clk),.en(write_sel[7] & write),.rst(rst));
      
   // 8 to 1 mux for register 1 data
   always @* case (read1regsel)
      3'b000 : read1data = reg0out;
      3'b001 : read1data = reg1out;
      3'b010 : read1data = reg2out;
      3'b011 : read1data = reg3out;
      3'b100 : read1data = reg4out;
      3'b101 : read1data = reg5out;
      3'b110 : read1data = reg6out;
      3'b111 : read1data = reg7out;
      default: read1data = 15'h0;
   endcase

   // 8 to 1 mux for register 2 data
   always @* case (read2regsel)
      3'b000 : read2data = reg0out;
      3'b001 : read2data = reg1out;
      3'b010 : read2data = reg2out;
      3'b011 : read2data = reg3out;
      3'b100 : read2data = reg4out;
      3'b101 : read2data = reg5out;
      3'b110 : read2data = reg6out;
      3'b111 : read2data = reg7out;
      default: read2data = 15'h0;
   endcase

   // 8 to 1 mux for register destination
   always @* case (writeregsel)
      3'b000 : reg0in = writedata;
      3'b001 : reg1in = writedata;
      3'b010 : reg2in = writedata;
      3'b011 : reg3in = writedata;
      3'b100 : reg4in = writedata;
      3'b101 : reg5in = writedata;
      3'b110 : reg6in = writedata;
      3'b111 : reg7in = writedata;
   endcase

   // we don't consider an error case for rf,
   // so err is tied low.
   assign err = 1'b0; 
endmodule
// DUMMY LINE FOR REV CONTROL :1: