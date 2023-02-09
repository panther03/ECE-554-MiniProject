#!/usr/bin/python3
"""
A script to run vsim testbenches for our repo structure.
Relies on the following folder structure:
tb/TEST1/{TEST1.mpf} -> top-level testbench has module name TEST1_tb

Julien de Castelnau
"""

import argparse
import json
import os
import subprocess
import sys

# path stuff (gotta love python..)
import os.path
import shutil
from pathlib import Path

def scan_rtl_files(tb_dir):
    all_files = []
    for (root,dirs,files) in os.walk("rtl/"):
        all_files += [os.path.relpath(root+"/"+f,tb_dir) for f in files if f.endswith(".v") or f.endswith(".sv")]
    for (root,dirs,files) in os.walk(tb_dir):
        all_files += [f for f in files if f.endswith(".v") or f.endswith(".sv")]
    print(all_files)
    return all_files

def proj(tb_dir, tb_name):

    modelsim_junk = [f"{tb_name}.mpf", f"{tb_name}.cr.mti", "transcript", "modelsim.ini"]
    for junk in modelsim_junk:
        if os.path.exists(os.path.join(tb_dir,junk)):
            os.remove(os.path.join(tb_dir,junk))
        
    work_dir = f"{tb_dir}/work"
    if os.path.exists(work_dir):
        shutil.rmtree(work_dir)
    
    files = scan_rtl_files(tb_dir)
    file_commands = " ".join([f"project addfile {f};" for f in files])
    vsim_command = f"\
        vsim -c -do \"project new . {tb_name}; project open {tb_name}; {file_commands}; quit\"\
    "
    result = subprocess.run(vsim_command, shell=True, cwd=tb_dir).returncode

def gui(tb_dir, tb_name):
    vsim_command = f"\
        vsim -gui -do \"project open ./{tb_name}.mpf;\"\
    "
    result = subprocess.Popen(vsim_command, shell=True, cwd=tb_dir)

def test(tb_dir, tb_name, top):
    print("????")
    vsim_command = f"\
        vsim -c -do \"project open ./{tb_name}.mpf; project compileall; vsim -c work.{top}; run -all; quit\"\
    "
    result = subprocess.run(vsim_command, shell=True, cwd=tb_dir).returncode



#def test_tb(tb_name):
#    vsim_command = f"\
#        vsim -c -do \"cd tb/{tb_name}; project open {tb_name}; project compileall; vsim -c work.{tb_name}_tb; run -all; quit\"\
#    "
#    result = subprocess.run(vsim_command, shell=True).returncode
#    return result
# project compileall; vsim -c work.{tb_name}_tb; run -all; quit

def run_flow(flow, tb, tb_cfg):
    tb_dir = f"tb/{tb}/"

    if not os.path.exists(tb_dir):
        raise RuntimeError(f"tb directory {tb_dir} doesn't exist. Quitting.")

    fw_file = tb_cfg["fw"]
    if fw_file:
        subprocess.run(f"python3 sw/assemble.py fw/{fw_file} -o out/out.hex", shell=True, check=True, capture_output=True)

#    if flow == "test":
#
#    elif flow == "gui":
#
    if flow == "proj":
        proj(tb_dir, tb)
    elif flow == "gui":
        proj(tb_dir, tb)
        gui(tb_dir, tb)
    else: # flow == "test"
        proj(tb_dir, tb)
        test(tb_dir, tb, tb_cfg["top"])


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument("flow", choices=["test", "gui", "proj"])
    parser.add_argument("tb", nargs='?', default=None)
    args = parser.parse_args()

    try:
        with open("tb.json", 'r') as f:
            tb_json = json.load(f)
    except FileNotFoundError:
        raise RuntimeError("I could not find tb.json in the current directory. Did you execute this file from the 'sw/' directory? You should be in the root of the repo.")

    if args.tb is None:
        for (tb, tb_cfg) in tb_json.items():
            results = run_flow(args.flow, tb, tb_cfg)
    else:
        if (tb_cfg := tb_json[args.tb]):
            results = run_flow(args.flow, args.tb, tb_cfg)
        else:
            raise RuntimeError(f"Could not find {args.tb} in tb.json!")

    """else:
        for dir_name in os.listdir(TB_DIR):
            res = run_tb(dir_name)
            if res:
                # means one of em failed
                print("One of the testbenches failed!", file=sys.stderr)
                exit(res)

    print("Yahoo! All testbenches passed...")
    exit(0)"""

    