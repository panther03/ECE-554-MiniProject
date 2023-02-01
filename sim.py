#!/usr/bin/python3
"""
A script to run vsim testbenches for our repo structure.
Relies on the following folder structure:
tb/TEST1/{TEST1.mpf} -> top-level testbench has module name TEST1_tb

Julien de Castelnau
"""

import argparse
import subprocess
import os
import sys

TB_DIR="tb/"

def run_tb(tb_name):
    vsim_command = f"\
        vsim -c -do \"cd {TB_DIR}/{tb_name}; project open {tb_name}; project compileall; vsim -c work.{tb_name}_tb; run -all; quit\"\
    "
    result = subprocess.run(vsim_command, shell=True).returncode
    return result

if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument("-t", "--tb", help="Specify a testbench to run in particular. Defaults to all")

    args = parser.parse_args()

    if args.tb is not None:
        res = run_tb(args.tb)
        if res:
            print(f"Testbench {args.tb} failed!")
            exit(res)
    else:
        for dir_name in os.listdir(TB_DIR):
            res = run_tb(dir_name)
            if res:
                # means one of em failed
                print("One of the testbenches failed!", file=sys.stderr)
                exit(res)

    print("Yahoo! All testbenches passed...")
    exit(0)

    