# A terrible assembler for WISC-SP13
# Good luck trying to decipher errors from this thing
# Julien de Castelnau

#!/usr/bin/env python3
import sys
import re
from enum import Enum
import argparse

sys.tracebacklimit = 0 # this shit is super annoying

opcodes = {
    "halt" : "00000",
    "nop"  : "00001",
    "addi" : "01000",
    "subi" : "01001",
    "xori" : "01010",
    "andni": "01011",
    "roli" : "10100",
    "slli" : "10101",
    "rori" : "10110",
    "srli" : "10111",
    "st"   : "10000",
    "ld"   : "10001",
    "stu"  : "10011",
    "btr"  : "11001",
    "add"  : "11011",
    "sub"  : "11011",
    "xor"  : "11011",
    "andn" : "11011",
    "rol"  : "11010",
    "sll"  : "11010",
    "ror"  : "11010",
    "srl"  : "11010",
    "seq"  : "11100",
    "slt"  : "11101",
    "sle"  : "11110",
    "sco"  : "11111",
    "beqz" : "01100",
    "bnez" : "01101",
    "bltz" : "01110",
    "bgez" : "01111",
    "lbi"  : "11000",
    "slbi" : "10010",
    "j"    : "00100",
    "jr"   : "00101",
    "jal"  : "00110",
    "jalr" : "00111",
}

rformat_ext = {
    "add" : "00",
    "sub" : "01",
    "xor" : "10",
    "andn": "11",
    "rol" : "00",
    "sll" : "01",
    "ror" : "10",
    "srl" : "11",
    "seq" : "00", # technically don't-care
    "slt" : "00",
    "sle" : "00",
    "sco" : "00"
}

regs = {
    "r0" : "000",
    "r1" : "001",
    "r2" : "010",
    "r3" : "011",
    "r4" : "100",
    "r5" : "101",
    "r6" : "110",
    "r7" : "111"
}

class LabelType(Enum):
    INST = 0
    UPPER = 1
    LOWER = 2

IMM_BITS_SHORT = 5
IMM_BITS_LONG = 8
IMM_BITS_DISPLACEMENT = 11

def safe_hex_convert(s):
    try: 
        return int(s, base=16)
    except ValueError:
        return None

def parse_reg(reg_str):
    if (reg_num := regs.get(reg_str)):
        return reg_num
    else:
        raise ValueError(f"Unrecognized register {reg_str}.")

def parse_imm(imm_str, imm_bits=IMM_BITS_SHORT):
    val = 0
    try: 
        if imm_str.startswith("0x"):
            val = int(imm_str, base = 16)
        else:
            val = int(imm_str, base = 10)
    except ValueError:
        raise ValueError(f"Invalid immediate {imm_str} provided.")

    # cba'd to add an option to do the proper positive check if its being used as signed
    if val > ((1 << imm_bits) - 1) or val < -(1 << (imm_bits - 1)):
        raise ValueError(f"Immediate value {imm_str} truncated, too large or small for range.")

    bin_str = ""
    for i in range(imm_bits-1, -1, -1):
        if val & (1 << i):
            bin_str += "1"
        else:
            bin_str += "0"
    
    return bin_str

def validate_ilabel(label_in):
    if re.match("^\.\w+$", label_in):
        return label_in
    else:
        return None

def validate_dlabel(label_in):
    if re.match("^l\.\w+$", label_in):
        return (label_in,LabelType.LOWER)
    elif re.match("^u\.\w+$", label_in):
        return (label_in,LabelType.UPPER)
    else:
        return None

def parse_instruction(asm_s):
    iword = "x" * 16 # a placeholder
    label = None
    ltype = LabelType.INST

    op = asm_s[0].lower()
    rest = "".join(asm_s[1:]).lower().split(",") # re-split it by comma and convert to lowercase, these are now parameters

    if op in ["halt", "nop"] and len(rest) == 1:
        iword = opcodes[op] + "0" * 11
    elif op in ["addi", "subi", "xori", "andni", "roli", "slli", "rori", "srli", "st", "ld", "stu"] and len(rest) == 3:
        rd = parse_reg(rest[0])
        rs = parse_reg(rest[1])
        imm = parse_imm(rest[2])
        
        iword = opcodes[op] + rs + rd + imm
    elif op in ["addi", "subi", "xori", "andni", "roli", "slli", "rori", "srli", "st", "ld", "stu"] and len(rest) == 2:
        # This is the same as above but when it's missing the immediate,
        # we will just take it to be 0
        rd = parse_reg(rest[0])
        rs = parse_reg(rest[1])
        imm = "00000"
        
        iword = opcodes[op] + rs + rd + imm
    elif op in ["btr"] and len(rest) == 2:
        rd = parse_reg(rest[0])
        rs = parse_reg(rest[1])

        iword = opcodes[op] + rs + "000" + rd + "00"
    elif op in rformat_ext.keys() and len(rest) == 3:
        rd = parse_reg(rest[0])
        rs = parse_reg(rest[1])
        rt = parse_reg(rest[2])
        xt = rformat_ext[op]

        iword = opcodes[op] + rs + rt + rd + xt
    elif op in ["beqz", "bnez", "bltz", "bgez", "jr", "jalr"] and len(rest) == 2:
        rs = parse_reg(rest[0])
        label = validate_ilabel(rest[1])
        if label: # this will be set so we know to fill in the immediate later
            iword = opcodes[op] + rs
        else:
            # assume it is a number immediate so have to do now
            imm = parse_imm(rest[1], imm_bits = IMM_BITS_LONG)
            iword = opcodes[op] + rs + imm
    elif op in ["lbi", "slbi"] and len(rest) == 2:
        rs = parse_reg(rest[0])
        label_tuple = validate_dlabel(rest[1])
        if label_tuple:
            label, ltype = label_tuple
            iword = opcodes[op] + rs
        else:
            imm = parse_imm(rest[1], imm_bits = IMM_BITS_LONG)
            iword = opcodes[op] + rs + imm
    elif op in ["j", "jal"] and len(rest) == 1:
        label = validate_ilabel(rest[0])
        if label: # this will be set so we know to fill in the immediate later
            iword = opcodes[op]
        else:
            # assume it is a number immediate so have to do now
            imm = parse_imm(rest[0], imm_bits = IMM_BITS_DISPLACEMENT)
            iword = opcodes[op] + imm
    else:
        asm_s_j = " ".join(asm_s)
        raise SyntaxError(f"Did not understand the instruction: {asm_s_j}")

    return (iword, label, ltype)

def first_pass(asm_lines):
    # These are lists of memory words for instructions and data respectively
    # imem will contain incomplete words that still need to be filled in with label addresses
    imem = []

    # This is a list of strings corresponding to code
    code = []

    # A dictionary of labels => addresses
    # one for instrs, one for data  
    labels = {}

    for asm_line in asm_lines:
        # If we see a comment, we will cut off everything after it on that line
        # Treat the line as though it had that part removed
        if (r := re.search("//.*$", asm_line)):
            asm_line = asm_line[:r.start()]

        # always strip surrounding whitespace
        asm_line = asm_line.strip()

        # The line is empty or just whitespace
        # Any of these conditions are acceptable and we will just ignore
        if not asm_line:
            pass
        # Checking for instruction labels
        elif (r := re.match("^\.\w+:$", asm_line)):
            label = r.string[:-1].lower()
            labels[label] = len(imem) * 2
        else:
            # going to attempt to view this as an instruction
            asm_s = asm_line.split()
            # special case for handling data directive
            if len(asm_s) == 2 and asm_s[0].lower() == "data" and (dval := safe_hex_convert(asm_s[1])):
                imem.append((parse_imm(asm_s[1], imm_bits = 16), None, LabelType.INST))
                code.append(" ".join(asm_s))
            elif len(asm_s) >= 1 and asm_s[0].lower() in opcodes.keys():
                imem.append(parse_instruction(asm_s))
                code.append(" ".join(asm_s))
            # otherwise not sure what i'm looking at
            else:
                raise SyntaxError(f"Did not understand the instruction: {asm_line}")

    return imem, code, labels

def second_pass(imem, labels):
    """To fill in the labels."""
    new_imem = []
    pc = 0
    for (inst, label, ltype) in imem:
        new_inst = inst
        if label:
            if ltype == LabelType.LOWER:
                label_addr = labels.get(label[1:])
                if label_addr is None:
                    raise ValueError(f"Invalid data label {label[1:]} provided.")
                imm_val = parse_imm(str(label_addr & 0xFF), imm_bits = 16 - len(inst))
            elif ltype == LabelType.UPPER:
                label_addr = labels.get(label[1:])
                if label_addr is None:
                    raise ValueError(f"Invalid data label {label[1:]} provided.")
                imm_val = parse_imm(str((label_addr >> 8) & 0xFF), imm_bits = 16 - len(inst))
            else: # LabelType.INST
                label_addr = labels.get(label)
                if label_addr is None:
                    raise ValueError(f"Invalid instruction label {label} provided.")
                offset = label_addr - (pc + 2)
                imm_val = parse_imm(str(offset), imm_bits = 16 - len(inst))

            new_inst += imm_val 

        new_imem.append(new_inst)
        pc += 2

    return new_imem

if __name__ == "__main__":

    parser = argparse.ArgumentParser()

    parser.add_argument("in_file")
    parser.add_argument("-o", "--out_file")
    parser.add_argument("-d", "--debug_file", action='store_true')

    args = parser.parse_args()

    with open(args.in_file, 'r') as asm_f:
        asm_lines = asm_f.readlines()
        imem, code, labels = first_pass(asm_lines)
        new_imem = second_pass(imem, labels)

        labels_reversed = {}
        for (k,v) in labels.items():
            labels_reversed[v] = k

        if args.out_file:
            hex_out = open(args.out_file, 'w')

        if args.debug_file:
            debug_out = open("debug.out", 'w')
            debug_out.write("@0\n")
        
        addr = 0
        for (inst_bin, code) in zip(new_imem, code):
            inst_val = int(inst_bin, base=2)
            if (label_name := labels_reversed.get(addr)):
                hex_str = f"@{addr:04x} {inst_val:04x}  // {label_name}: {code}"
            else:
                hex_str = f"@{addr:04x} {inst_val:04x}  // {code}"
            if args.out_file:
                hex_out.write(hex_str + "\n")
            if args.debug_file:
                inst_val_str = format(inst_val, "04x")
                debug_out.writelines([inst_val_str[:2] + "\n", inst_val_str[2:] + "\n"])
            else:
                print(hex_str)
            addr += 2

        if args.out_file:
            hex_out.close()

        if args.debug_file:
            debug_out.close()
