/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module rf (
           // Outputs
           read1data, read2data, err,
           // Inputs
           clk, rst_n, read1regsel, read2regsel, writeregsel, writedata, write
           );
   input clk, rst_n;
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

   reg16 iREG0 (.q(reg0out),.d(reg0in),.clk(clk),.en(write_sel[0] & write),.rst_n(rst_n));
   reg16 iREG1 (.q(reg1out),.d(reg1in),.clk(clk),.en(write_sel[1] & write),.rst_n(rst_n));
   reg16 iREG2 (.q(reg2out),.d(reg2in),.clk(clk),.en(write_sel[2] & write),.rst_n(rst_n));
   reg16 iREG3 (.q(reg3out),.d(reg3in),.clk(clk),.en(write_sel[3] & write),.rst_n(rst_n));
   reg16 iREG4 (.q(reg4out),.d(reg4in),.clk(clk),.en(write_sel[4] & write),.rst_n(rst_n));
   reg16 iREG5 (.q(reg5out),.d(reg5in),.clk(clk),.en(write_sel[5] & write),.rst_n(rst_n));
   reg16 iREG6 (.q(reg6out),.d(reg6in),.clk(clk),.en(write_sel[6] & write),.rst_n(rst_n));
   reg16 iREG7 (.q(reg7out),.d(reg7in),.clk(clk),.en(write_sel[7] & write),.rst_n(rst_n));
      
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
      3'b000 : begin reg0in = writedata; reg1in = 0; reg2in = 0; reg3in = 0; reg4in = 0; reg5in = 0; reg6in = 0; reg7in = 0; end
      3'b001 : begin reg1in = writedata; reg0in = 0; reg2in = 0; reg3in = 0; reg4in = 0; reg5in = 0; reg6in = 0; reg7in = 0; end
      3'b010 : begin reg2in = writedata; reg0in = 0; reg1in = 0; reg3in = 0; reg4in = 0; reg5in = 0; reg6in = 0; reg7in = 0; end
      3'b011 : begin reg3in = writedata; reg0in = 0; reg1in = 0; reg2in = 0; reg4in = 0; reg5in = 0; reg6in = 0; reg7in = 0; end
      3'b100 : begin reg4in = writedata; reg0in = 0; reg1in = 0; reg2in = 0; reg3in = 0; reg5in = 0; reg6in = 0; reg7in = 0; end
      3'b101 : begin reg5in = writedata; reg0in = 0; reg1in = 0; reg2in = 0; reg3in = 0; reg4in = 0; reg6in = 0; reg7in = 0; end
      3'b110 : begin reg6in = writedata; reg0in = 0; reg1in = 0; reg2in = 0; reg3in = 0; reg4in = 0; reg5in = 0; reg7in = 0; end
      3'b111 : begin reg7in = writedata; reg0in = 0; reg1in = 0; reg2in = 0; reg3in = 0; reg4in = 0; reg5in = 0; reg6in = 0; end
   endcase

   // we don't consider an error case for rf,
   // so err is tied low.
   assign err = 1'b0; 
endmodule
// DUMMY LINE FOR REV CONTROL :1: