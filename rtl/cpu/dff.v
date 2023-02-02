/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
// D-flipflop

module dff (q, d, clk, rst_n);

    output reg        q;
    input          d;
    input          clk;
    input          rst_n;

    always @(posedge clk, negedge rst_n)
      if (!rst_n)
        q <= 0;
      else
        q <= d;
      

endmodule
// DUMMY LINE FOR REV CONTROL :0:
