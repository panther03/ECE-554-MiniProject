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

   reg [15:0] rf1 [7:0];
   reg [15:0] rf2 [7:0];

   always @(negedge clk) begin
      if (write) begin
         rf1[writeregsel] <= writedata;
         rf2[writeregsel] <= writedata;
      end
      read1data <= rf1[read1regsel];
      read2data <= rf2[read2regsel];
   end

   // we don't consider an error case for rf,
   // so err is tied low.
   assign err = 1'b0; 
endmodule
// DUMMY LINE FOR REV CONTROL :1: