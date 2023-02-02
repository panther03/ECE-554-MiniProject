module forward (EX_MEM_regw, MEM_WB_regw, IF_ID_reg1, IF_ID_reg2, ID_EX_reg1, ID_EX_reg2,
                frwrd_MEM_EX_opA, frwrd_MEM_EX_opB, frwrd_WB_EX_opA, frwrd_WB_EX_opB, frwrd_EX_ID_opA, 
                bypass_reg1, bypass_reg2, EX_MEM_ctrl_regw, MEM_WB_ctrl_regw);

input [2:0] EX_MEM_regw, MEM_WB_regw, 
     IF_ID_reg1, IF_ID_reg2,
     ID_EX_reg1, ID_EX_reg2;
input EX_MEM_ctrl_regw, MEM_WB_ctrl_regw;

output frwrd_MEM_EX_opA, frwrd_MEM_EX_opB,
     frwrd_WB_EX_opA, frwrd_WB_EX_opB,
     frwrd_EX_ID_opA;
output bypass_reg1, bypass_reg2;

// EX to EX forwarding under other terminology
assign frwrd_MEM_EX_opA = (EX_MEM_ctrl_regw) & (EX_MEM_regw == ID_EX_reg1);
assign frwrd_MEM_EX_opB = (EX_MEM_ctrl_regw) & (EX_MEM_regw == ID_EX_reg2);

// MEM to EX forwarding under other terminology
assign frwrd_WB_EX_opA = (MEM_WB_ctrl_regw) & (MEM_WB_regw == ID_EX_reg1);
assign frwrd_WB_EX_opB = (MEM_WB_ctrl_regw) & (MEM_WB_regw == ID_EX_reg2);

// register bypass
assign bypass_reg1 = (MEM_WB_ctrl_regw) & (MEM_WB_regw == IF_ID_reg1);
assign bypass_reg2 = (MEM_WB_ctrl_regw) & (MEM_WB_regw == IF_ID_reg2);

// EX to ID forwrding under other terminology (for branch)
assign frwrd_EX_ID_opA = (EX_MEM_ctrl_regw) & (EX_MEM_regw == IF_ID_reg1);

endmodule