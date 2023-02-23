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

def rtl_files_in_root(root, files, tb_dir):
    return [os.path.relpath(root+"/"+f,tb_dir) for f in files if f.endswith(".v") or f.endswith(".sv")]

def scan_files(tb_dir, fileset, tb_pkgs):
    all_files = []

    # RTL pkg files always go first. we will scan these first. 
    for (root,_,files) in os.walk("rtl/pkg/"):
        all_files += rtl_files_in_root(root, files, tb_dir)

    if fileset:
        all_files += [os.path.relpath(f,tb_dir) for f in fileset]
    else:
        for (root,_,files) in os.walk("rtl/"):
            if "pkg" not in root:
                all_files += rtl_files_in_root(root, files, tb_dir)

    tb_files = []
    for (root,dirs,files) in os.walk(tb_dir):    
        if "pkg" not in root:
            tb_files += [f for f in files if f.endswith(".v") or f.endswith(".sv")]
    
    # now we add the list of specified testbench packages (if specified)
    if tb_pkgs:
        for tb_pkg in tb_pkgs:
            # file always ends in .sv because packages are a SystemVerilog feature.
            tb_pkg_path = f"tb/pkg/{tb_pkg}.sv"
            if not os.path.exists(tb_pkg_path):
                raise RuntimeError(f"Invalid package {tb_pkg} specified. Could not find {tb_pkg_path}.")
            else:
                all_files += [os.path.relpath(tb_pkg_path,tb_dir)]
    
    # now finally add our testbench files (these must come after TB support packages)
    all_files += tb_files

    return all_files

def clean(tb_dir, tb_name):
    modelsim_junk = [f"{tb_name}.mpf", f"{tb_name}.cr.mti", "transcript", "modelsim.ini", "vsim.wlf", "vsim_stacktrace.wlf"]
    for junk in modelsim_junk:
        if os.path.exists(os.path.join(tb_dir,junk)):
            os.remove(os.path.join(tb_dir,junk))
        
    work_dir = f"{tb_dir}/work"
    if os.path.exists(work_dir):
        shutil.rmtree(work_dir)

def proj(tb_dir, tb_name, fileset, tb_pkgs):    
    files = scan_files(tb_dir, fileset, tb_pkgs)
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

def run_flow(flow, tb, tb_cfg):
    tb_dir = f"tb/{tb}/"

    if not os.path.exists(tb_dir):
        raise RuntimeError(f"tb directory {tb_dir} doesn't exist. Quitting.")

    fw_file = tb_cfg.get("fw")
    if fw_file:
        subprocess.run(f"python3 sw/assemble.py fw/{fw_file} -o out/out.hex", shell=True, check=True, capture_output=True)

    top = tb_cfg["top"]
    fileset = tb_cfg.get("files")
    tb_pkgs = tb_cfg.get("tb_pkgs")

    # always clean first
    clean(tb_dir, tb)
    # quit here if we're just doing a clean
    if flow == "clean":
        return
    # otherwise assume proj by default
    proj(tb_dir, tb, fileset, tb_pkgs)
    if flow == "gui":
        gui(tb_dir, tb)
    elif flow == "test":
        return test(tb_dir, tb, top)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument("flow", choices=["test", "gui", "proj", "clean"])
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
    
