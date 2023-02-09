
# Verilog Style

Please feel free to discuss any of these rules with me. I am just copying style from the code I find easiest to read and maintain. I am also making up a lot of them as I go. I will probably try to tweak code that is not written to style, if we are not crunched for time, but won't enforce it super heavily.

* For all modules:
    * All reg signals should be declared with an "_r".
    * Never declare output signals as reg. Keep the "_o" suffix and assign them to registers at the bottom of your file.
        * This makes it easier to organize the signal list at the top, and you can see all of the outputs at the bottom.
    * Use Verilog-2001 ANSI-style port declaration:
        BAD: 
        ```verilog
        module (A, B, C);
        input A;
        input B;
        input C;
        ```
        GOOD:
        ```verilog
        module (
            input A,
            input B,
            input C
        );
        ```
    * All signals that are active low should have the suffix "_n" (**Put this before "_o/_i" and "_r"**)
    * Don't put all the signals on one line when doing a module instantiation. Break it up so you have maximum 1-2 signals per line. 
* For non-top level modules:
    * All input signals **except for clk and rst_n** should be declared with an "_i" suffix.
    * All output signals should be declared with an "_o" suffix.
* For top level modules:
    * Whenever possible, you should try to match the signal name to the name present on the schematic.
    * If it's not on the schematic, it doesn't need an "_o" or "_i" suffix (this is just to be consistent with the previous rule.)