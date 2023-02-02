/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
//`timescale 1ns/1ns

module proc_hier();
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 clk;                    // From c0 of clkrst_n.v
   wire                 err;                    // From p0 of proc.v
   wire                 rst_n;                    // From c0 of clkrst_n.v
   // End of automatics
   clkrst_n c0(/*AUTOINST*/
             // Outputs
             .clk                       (clk),
             .rst_n                       (rst_n),
             // Inputs
             .err                       (err));
   
   proc p0(/*AUTOINST*/
           // Outputs
           .err                         (err),
           // Inputs
           .clk                         (clk),
           .rst_n                         (rst_n));   
   

endmodule

// DUMMY LINE FOR REV CONTROL :0:
