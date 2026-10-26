#custom built assembler that follows the RISC V documentation for the base instruction set
#uses a map with all instructions, no pseudos however
#can use labels attached to a colon, eg: my_label:
#labels can be passed for jumps and branches as the target, or can be set as a number to be added to pc


import re
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

if len(sys.argv) > 1:
    asm_path = os.path.abspath(sys.argv[1])
else:
    asm_path = os.path.join(SCRIPT_DIR, 'assembly.asm')
my_map = {
    'add' : (0b0110011, 0x0, 0x00),
    'sub' : (0b0110011, 0x0, 0x20),
    'xor' : (0b0110011, 0x4, 0x00),
    'or' : (0b0110011, 0x6, 0x00),
    'and' : (0b0110011, 0x7, 0x00),
    'sll' : (0b0110011, 0x1, 0x00),
    'srl' : (0b0110011, 0x5, 0x00),
    'sra' : (0b0110011, 0x5, 0x20),
    'slt' : (0b0110011, 0x2, 0x00),
    'sltu': (0b0110011, 0x3, 0x00),

    'addi': (0b0010011, 0x0, 0x00),
    'xori': (0b0010011, 0x4, 0x00),
    'ori': (0b0010011, 0x6, 0x00),
    'andi': (0b0010011, 0x7, 0x00),
    'slli': (0b0010011, 0x1, 0x00),
    'srli': (0b0010011, 0x5, 0x00),
    'srai': (0b0010011, 0x5, 0x20),
    'slti': (0b0010011, 0x2, 0x00),
    'sltiu': (0b0010011, 0x3,0x00),

    'lb' : (0b0000011, 0x0),
    'lh' : (0b0000011, 0x1),
    'lw' : (0b0000011, 0x2),
    'lbu': (0b0000011, 0x4),
    'lhu': (0b0000011, 0x5),

    'sb':(0b0100011, 0x0),
    'sh': (0b0100011, 0x1),
    'sw': (0b0100011, 0x2),

    'beq' : (0b1100011, 0x0),
    'bne' : (0b1100011, 0x1),
    'blt' : (0b1100011, 0x4),
    'bge' : (0b1100011, 0x5),
    'bltu': (0b1100011, 0x6),
    'bgeu': (0b1100011, 0x7),

    'jal': (0b1101111,),
    'jalr': (0b1100111, 0x0),

    'lui': (0b0110111,),
    'auipc': (0b0010111,),

    'mul': (0b0110011, 0x0, 0x01),
    'mulh': (0b0110011, 0x1, 0x01),
    'mulhsu': (0b0110011, 0x2, 0x01),
    'mulhu':(0b0110011, 0x3,0x01),

    'div': (0b0110011, 0x4, 0x01),
    'divu': (0b0110011, 0x5, 0x01),
    'rem': (0b0110011, 0x6, 0x01),
    'remu': (0b0110011, 0x7, 0x01),
    'ebreak': (0b1110011, 0x0, 0x01)  #imm field is 1 (imm 0 would be ecall)

}


pseudo_map = {
    'nop': ('addi', ['x0', 'x0', '0']),
    'mv' : ('addi', ['{0}', '{1}', '0' ]),

    'not' : ('xori', ['{0}', '{1}', '-1']),
    'neg': ('sub', ['{0}', 'x0', '{1}']),

    'seqz':('sltiu', ['{0}', '{1}', '1']),
    'snez':('sltu', ['{0}', 'x0', '{1}']),
    'sltz':('slt', ['{0}', '{1}', 'x0']),
    'sgtz':('slt', ['{0}', 'x0', '{1}']),

    'beqz':('beq', ['{0}', 'x0', '{1}']),
    'bnez':('bne', ['{0}', 'x0', '{1}']),
    'blez':('bge', ['x0', '{0}', '{1}']),
    'bgez':('bge', ['{0}', 'x0', '{1}']),
    'bltz':('blt', ['{0}', 'x0', '{1}']),
    'bgtz':('blt', ['x0', '{0}', '{1}']),

    'bgt':('blt', ['{1}', '{0}', '{2}']),
    'ble':('bge', ['{1}', '{0}', '{2}']),
    'bgtu':('bltu', ['{1}', '{0}', '{2}']),
    'bleu':('bgeu', ['{1}', '{0}', '{2}']),

    'j':('jal', ['x0', '{0}']),
    'jr':('jalr', ['x0', '{0}', '0']),
    'ret':('jalr', ['x0', 'x1', '0']),
}


class AsmError(Exception):
    #raised for any problem with a line; caught per line so every error gets reported
    pass


errors = []   # (source line number, message)


def parse_int(tok):
    #accepts decimal, 0x hex, 0b binary, 0o octal, with optional sign
    t = tok.strip()
    try:
        return int(t, 0)
    except ValueError:
        pass
    try:
        return int(t, 10)   #int(x, 0) rejects leading zeros like "010", keep accepting them as decimal
    except ValueError:
        raise AsmError(f"invalid immediate '{t}'")


def is_number(tok):
    return re.fullmatch(r'[+-]?(0[xX][0-9a-fA-F]+|0[bB][01]+|0[oO][0-7]+|\d+)', tok.strip()) is not None


def check_range(value, lo, hi, what):
    if not lo <= value <= hi:
        raise AsmError(f"{what} {value} is out of range ({lo}..{hi})")
    return value


def imm(tok, lo, hi, what):
    return check_range(parse_int(tok), lo, hi, what)


def reg(tok):
    #normalizes ABI names and x-names (any case, any surrounding whitespace) to a register number
    t = tok.strip().lower()
    t = register_map.get(t, t)
    if not re.fullmatch(r'x([0-9]|[12][0-9]|3[01])', t):
        raise AsmError(f"invalid register '{tok.strip()}'")
    return int(t[1:])


def label_addr(name):
    name = name.strip()
    if name not in labels:
        raise AsmError(f"undefined label '{name}'")
    return labels[name]


def target_offset(tok, pc, bits, what):
    #a plain number is a raw offset added to pc, otherwise it is a label
    if is_number(tok):
        offset = parse_int(tok)
    else:
        offset = label_addr(tok) - pc
    if offset % 2:
        raise AsmError(f"{what} offset {offset} must be a multiple of 2")
    return check_range(offset, -(1 << (bits - 1)), (1 << (bits - 1)) - 2, f"{what} offset")


hexout = ""
def decode_pseudo(pseudo_code, operands):
    temp_line = ""
    new_op, template = pseudo_map[pseudo_code]
    expected = len({part for part in template if part.startswith("{")})
    if len(operands) != expected:
        raise AsmError(f"'{pseudo_code}' expects {expected} operand(s), got {len(operands)}")
    temp_line += new_op + " "
    if template:
        for part in template:
            if part.startswith("{"):

                temp_line += operands[int(part[1])] + ", "
            else:
                temp_line += part + ", "
            ret_line = temp_line.rstrip(", ")

    return ret_line + "\n"

def li_decode(operands):
    if len(operands) != 2:
        raise AsmError(f"'li' expects 2 operands, got {len(operands)}")
    final_line = []
    temp_line = ""

    imm = parse_int(operands[1])
    check_range(imm, -(1 << 31), 0xFFFFFFFF, "li value")
    if imm >= (1 << 31):    #treat values like 0xFFFFFFFF as their signed 32-bit equivalent
        imm -= (1 << 32)
    if imm > 2047 or imm < -2048:
        upper =  (imm + 0x800) >> 12
        lower = imm - (upper << 12)
        temp_line =  "lui " + operands[0] + ", " + str(upper)
        final_line.append(temp_line)

        temp_line = "addi " + operands[0] + ", " + operands[0] + ", " + str(lower)
        final_line.append(temp_line)

    else:
        temp_line += "addi " + operands[0] + ", "  + "x0, " + str(imm)
        final_line.append(temp_line)
    return final_line

def call_decode(operands):
    if len(operands) != 1:
        raise AsmError(f"'call' expects 1 operand, got {len(operands)}")
    symbol = operands[0].strip()
    return [f"auipc x1, %hi({symbol})\n", f"jalr x1, x1, %lo({symbol})\n"]

def la_decode(operands):
    if len(operands) != 2:
        raise AsmError(f"'la' expects 2 operands, got {len(operands)}")
    rd = operands[0].strip()
    symbol = operands[1].strip()
    return [f"auipc {rd}, %hi({symbol})\n", f"addi {rd}, {rd}, %lo({symbol})\n"]


register_map = {
    "zero" : "x0",
    "ra" : "x1",
    "sp" : "x2",
    "gp" : "x3",
    "tp" : "x4",
    "t0" : "x5",
    "t1" : "x6",
    "t2" : "x7",
    "s0" : "x8",
    "fp" : "x8",
    "s1" : "x9",
    "a0" : "x10",
    "a1" : "x11",
    "a2" : "x12",
    "a3" : "x13",
    "a4" : "x14",
    "a5" : "x15",
    "a6" : "x16",
    "a7" : "x17",
    "s2": "x18",
    "s3" : "x19",
    "s4" : "x20",
    "s5" : "x21",
    "s6" : "x22",
    "s7" : "x23",
    "s8" : "x24",
    "s9" : "x25",
    "s10" :"x26",
    "s11" : "x27",
    "t3" : "x28",
    "t4" : "x29",
    "t5" : "x30",
    "t6" : "x31"
}


def encode_line(code, count):
    #code is one instruction with comments removed, count is its address
    tokens = code.split(None, 1)
    instr = tokens[0].lower()

    if instr not in my_map:
        raise AsmError(f"unknown instruction '{tokens[0]}'")
    entry = my_map[instr]
    opcode = entry[0]

    if instr == "ebreak":
        if len(tokens) != 1:
            raise AsmError("'ebreak' takes no operands")
        return entry[2] << 20 | opcode
    if len(tokens) == 1:
        raise AsmError(f"'{instr}' needs operands")

    if opcode != 0b0000011 and opcode != 0b0100011:
        params = [p.strip() for p in tokens[1].split(',')]
    else:
        #loads/saves: "rd, imm(rs1)" -> [rd, imm, rs1]
        params = [p.strip().rstrip(')').strip() for p in re.split(r'[,(]', tokens[1])]


    if opcode == 0b0110011 and len(params) == 3: #for R type if has the right number params

        funct3 = entry[1]
        funct7 = entry[2]
        rd = reg(params[0])
        rs1 = reg(params[1])
        rs2 = reg(params[2])


        intline =  funct7 << 25 |  rs2  << 20 | rs1 << 15 | funct3 << 12| rd << 7 | opcode


    elif opcode == 0b0110011:
        raise AsmError(f"R type instruction '{instr}' expects 3 operands, got {len(params)}")

    elif opcode == 0b0010011 and len(params) == 3: #I type

        funct3 = entry[1]
        rd = reg(params[0])
        rs1 = reg(params[1])
        if funct3 == 0x1 or funct3 == 0x5:
            shamt = imm(params[2], 0, 31, "shift amount")
            imm_field = entry[2] << 5 | shamt

        else:
            lo_match = re.match(r'%lo\((\w+)\)', params[2])
            if lo_match:
                addr = label_addr(lo_match.group(1)) - (count-4)
                upper = (addr + 0x800) >> 12
                immparam = addr - (upper << 12)
            elif is_number(params[2]):
                immparam = parse_int(params[2])
            else:
                immparam = label_addr(params[2]) - (count - 4)
            imm_field = check_range(immparam, -2048, 2047, "immediate") & 0xFFF

        intline = imm_field << 20 | rs1 << 15 | funct3 << 12 | rd << 7 | opcode


    elif opcode == 0b0010011:
        raise AsmError(f"I type instruction '{instr}' expects 3 operands, got {len(params)}")

    elif opcode == 0b0000011 and len(params) == 3: #loads

        funct3 = entry[1]
        rd = reg(params[0])
        rs1 = reg(params[2])
        imm_field = imm(params[1], -2048, 2047, "load offset") & 0xFFF

        intline = imm_field << 20 | rs1 << 15 | funct3 << 12 | rd << 7 | opcode

    elif opcode == 0b0000011:
        raise AsmError(f"load '{instr}' expects 'rd, offset(rs1)'")

    elif opcode == 0b0100011 and len(params) == 3: #saves

        funct3 = entry[1]
        rs2 = reg(params[0])
        rs1 = reg(params[2])
        imm_field = imm(params[1], -2048, 2047, "store offset") & 0xFFF

        intline =  ((imm_field >> 5) & 0x7F) << 25 | rs2 << 20 |  rs1 << 15 | funct3 << 12 | (imm_field & 0x1F) << 7  | opcode

    elif opcode == 0b0100011:
        raise AsmError(f"save '{instr}' expects 'rs2, offset(rs1)'")

    elif opcode == 0b1100011 and len(params) == 3: #branch

        funct3 = entry[1]
        rs1 = reg(params[0])
        rs2 = reg(params[1])
        imm_field = target_offset(params[2], count, 13, "branch") & 0x1FFF

        intline = (imm_field >> 12) << 31| ((imm_field >> 5) & 0x3F)  << 25 | rs2 << 20 | rs1 << 15 | funct3 << 12 |  ((imm_field >> 1) & 0xF) << 8 | ((imm_field >> 11) & 0x1) << 7 | opcode

    elif opcode == 0b1100011:
        raise AsmError(f"branch '{instr}' expects 3 operands, got {len(params)}")

    elif opcode == 0b1101111 and len(params) in (1, 2): #jal, or jal shorthand with rd = x1

        if len(params) == 2:
            rd = reg(params[0])
            target = params[1]
        else:
            rd = 1
            target = params[0]
        imm_field = target_offset(target, count, 21, "jump") & 0x1FFFFF

        intline = (imm_field >> 20) << 31 | ((imm_field >> 1) & 0x3FF) << 21 | ((imm_field >> 11) & 0x1) << 20 | ((imm_field >> 12) & 0xFF) << 12 | rd << 7 | opcode

    elif opcode == 0b1101111:
        raise AsmError(f"'jal' expects 1 or 2 operands, got {len(params)}")



    elif opcode in (0b0110111, 0b0010111) and len(params) == 2: #lui, auipc
        rd = reg(params[0])
        hi_match = re.match(r'%hi\((\w+)\)', params[1])
        if hi_match:
            addr = label_addr(hi_match.group(1)) - count
            imm_field = (addr + 0x800) >> 12
        else:
            #negative values allowed so li can pass the signed upper part
            imm_field = imm(params[1], -0x80000, 0xFFFFF, f"{instr} immediate")
        imm_field &= 0xFFFFF
        intline = (imm_field << 12) | (rd << 7) | opcode

    elif opcode in (0b0110111, 0b0010111):
        raise AsmError(f"'{instr}' expects 2 operands, got {len(params)}")

    elif opcode == 0b1100111 and len(params) == 3: # jalr
        funct3 = entry[1]
        rd = reg(params[0])
        rs1 = reg(params[1])
        lo_match = re.match(r'%lo\((\w+)\)', params[2])
        if lo_match:
            addr = label_addr(lo_match.group(1)) - (count -4)
            imm_field = addr & 0xFFF
        else:
            imm_field = imm(params[2], -2048, 2047, "jalr offset") & 0xFFF

        intline = (imm_field << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

    elif opcode == 0b1100111 and len(params) == 1: #jalr shortcut
        funct3 = entry[1]
        rd = 1
        rs1 = reg(params[0])
        imm_field = 0

        intline = (imm_field << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

    elif opcode == 0b1100111:
        raise AsmError(f"'jalr' expects 1 or 3 operands, got {len(params)}")

    else:
        raise AsmError(f"unhandled instruction '{instr}'")

    return intline


with open(asm_path, 'r') as file:
    pseudo_content = file.readlines()

#first pass: expand pseudo instructions, keeping each line's source line number
content = []
for lineno, line in enumerate(pseudo_content, 1):
    stripped = line.split('#')[0].strip()
    if stripped and not stripped.endswith(":"):
        parts = stripped.split(None, 1)
        instr = parts[0].lower()
        if len(parts) > 1:
            operands = [item.strip() for item in parts[1].split(",")]
        else:
            operands = []
        try:
            if instr in pseudo_map:
                new_cont = [decode_pseudo(instr, operands)]
            elif instr == "li":
                new_cont = li_decode(operands)
            elif instr == "call":
                new_cont = call_decode(operands)
            elif instr == "la":
                new_cont = la_decode(operands)
            else:
                new_cont = [line]
        except AsmError as e:
            errors.append((lineno, str(e)))
            new_cont = [None]   #placeholder so the line still takes up an address
        for new_line in new_cont:
            content.append((lineno, new_line))
    else:
        content.append((lineno, line))

#second pass: find label addresses
labels = {}
count = 0
for lineno, line in content:
    if line is None:
        count += 4
        continue
    stripped = line.split("#")[0].strip()
    if stripped.endswith(':'):
        labels[stripped[:-1].strip()] = count
    elif stripped:
        count += 4

#third pass: encode
count = 0
for lineno, line in content:
    if line is None:
        count += 4
        continue
    code = line.split("#")[0].strip()
    if not code or code.endswith(':'):
        continue
    try:
        intline = encode_line(code, count)
        hexout += f"{intline:08x}\n"
    except AsmError as e:
        errors.append((lineno, str(e)))
    count += 4   #always advance so later addresses and errors stay correct

if errors:
    for lineno, msg in sorted(errors, key=lambda e: e[0]):
        print(f"line {lineno}: error: {msg}\n    {pseudo_content[lineno - 1].strip()}", file=sys.stderr)
    print(f"{len(errors)} error(s), no output written", file=sys.stderr)
    sys.exit(1)

with open(os.path.join(SCRIPT_DIR, 'instmemp.hex'), 'w') as file:
    file.write((hexout))