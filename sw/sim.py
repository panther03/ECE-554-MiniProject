#!/usr/bin/python3
"""
A script to run vsim testbenches for our repo structure.

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
    return subprocess.run(vsim_command, shell=True, cwd=tb_dir, stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL, check=True).returncode

def gui(tb_dir, tb_name):
    vsim_command = f"\
        vsim -gui -do \"project open ./{tb_name}.mpf;\"\
    "
    result = subprocess.Popen(vsim_command, shell=True, cwd=tb_dir)

def test(tb_dir, tb_name, top):
    vsim_command = f"\
        vsim -c -do \"project open ./{tb_name}.mpf; project compileall; vsim -c work.{top}; run -all; quit\"\
    "
    result = subprocess.run(vsim_command, shell=True, cwd=tb_dir, capture_output=True, text=True)
    if sys.stdout.isatty():
        arrow = "\x1b[93m-> "
        end = "\x1b[0m"
        passed = "\x1b[32m passed!"
        failed = "\x1b[31m failed!"
    else:
        arrow = "-> "
        end = ""
        passed = " passed!"
        failed = " failed!"
    if "yahoo" in result.stdout.lower():
        print(arrow + tb_name + passed + end)
        return 0
    else:
        print(arrow + tb_name + failed + end)
        print(arrow + f"Here are the last 20 lines of ModelSim's output." + end)
        for line in result.stdout.splitlines()[-20:]:
            print(line)
        print(arrow + f"See {tb_dir}transcript for more details." + end)
        return 1


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

    fw_file = tb_cfg.get("fw")
    if fw_file:
        subprocess.run(f"python3 sw/assemble.py fw/{fw_file} -o out/out.hex", shell=True, check=True, capture_output=True)

    if flow == "proj":
        proj(tb_dir, tb)
    elif flow == "gui":
        proj(tb_dir, tb)
        gui(tb_dir, tb)
    else: # flow == "test"
        proj(tb_dir, tb)
        return test(tb_dir, tb, tb_cfg["top"])


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

    if args.tb:
        if (tb_cfg := tb_json[args.tb]):
            res = run_flow(args.flow, args.tb, tb_cfg)
            if res:
                exit(1)
            else:
                exit(0)
        else:
            raise RuntimeError(f"Could not find {args.tb} in tb.json!")
        

    else:
        res_or_all = False
        for (tb, tb_cfg) in tb_json.items():
            res = run_flow(args.flow, tb, tb_cfg)
            if res:
                res_or_all = True
        
        if res_or_all:
            exit(1)
        else:
            exit(0)
    