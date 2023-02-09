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

   wire [7:0] write_sel;

   // We had to add this synthesis directive becasue Quartus was inferring the small memory as registers
   (* ramstyle = "m10k" *) reg [15:0] rf1 [7:0];
   (* ramstyle = "m10k" *) reg [15:0] rf2 [7:0];

   // Write and read register results on the negative edge.
   // Register bypass happens outside of this module so
   // we do not need to worry about that write-during-read here.
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