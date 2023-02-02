module MiniLab0();


proc PROC (
   // Error signal
   .err(), 
   // Clock and reset
   .clk(), .rst_n(),
   // Instruction memory signals
   .iaddr(), .inst(),
   // Data memory signals
   .daddr(), .wr(), .en(), .data_in(), .data_out()
   );


    // Instruction memory
imem IMEM (.clk(), .addr(), .inst());

// Data memory
dmem DMEM (.clk(), .wr(), .en(), .addr(), .data_in(), .data_out());

endmodule