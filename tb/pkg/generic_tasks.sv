`timescale 1ns/100ps
package generic_tasks;
    
    task automatic assert_msg(input cond, input string msg);
        if (cond) begin
            $display("PASS: %s @ time = %t", msg, $time);
        end else begin
            $display("FAIL: %s @ time = %t", msg, $time);
            $stop();
        end
    endtask

endpackage