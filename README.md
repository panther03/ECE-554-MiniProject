# ECE 554 Mini Project repository

This repository contains the code for the mini projects for ECE 554 @ UW-Madison, Spring 2023.

Group members:

* Julien de Castelnau
* Elan Graupe

## Building requirements

All of the mentioned programs should be in `$PATH`.

* `make`
* `python3`
* Modelsim: `vsim`
* Quartus executables: `quartus_sh`, `quartus_pgm`

## How to build

* To build a SOF file for the DE1-SoC: `make fpga`
* To simulate all testbenches: `make sim`
* To simulate a specific testbench called `MyTB` (see [Repository Structure](#repository-structure)): `make sim TB=MyTB`
* To open the modelsim GUI for `MyTB`: `make gui TB=MyTB`

## I can't use the scripts. Where do I go?

* To open the quartus project: Double click the `*.qsf` in `fpga/de1_soc`.
    * Make sure the assembly file you want is built and placed in `out/out.hex`. See below simulation steps for building asm files.
* To simulate MiniLab0:
    * Create the ModelSim project manually. Add `tb/MiniLab0/MiniLab0_tb.sv` to the project. Add all of the files in `rtl/` (the design files) to the project.
    * Create `out/` in the root of the repository if it does not already exist.
    * From the root of the repository, run `python3 sw/assemble.py fw/MiniLab0.asm -o out/out.hex`.
    * Start simulation with `MiniLab0_tb` as the toplevel and run.


## Repository Structure

* `doc/`: Contains all documentation related to the project.
* `fpga/`: Contains quartus projects for each board, having their own directory with a Makefile inside. For instance, `fpga/de1_soc`.
* `fw/`: Contains all firmware to be run on the FPGA itself. Assembly files, potentially C files in the future, etc.
* `out/`: A folder autogenerated by the scripts. The memory modules look for the instruction memory listing in this folder, `out.hex`.
* `rtl/`: Contains all of the synthesizable design logic.
* `sw/`: Accessory software to run on the host PC. Automation scripts live here. E.g assembler, testbench runner
* `tb/`: Contains a folder within for each testbench.
* `tb.json`: A JSON file used by the automation scripts to associate each testbench folder with a top level Verilog module, and a firmware file to automatically build.



## Verilog Style

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
