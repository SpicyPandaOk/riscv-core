#custom built assembler that follows the RISC V documentation for the base instruction set
#uses a map with all instructions, no pseudos however
#can use labels attached to a colon, eg: my_label:
#labels can be passed for jumps and branches as the target, or can be set as a number to be added to pc


import re
import os
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

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
    'auipc': (0b0010111,)

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
    'call':('jal', ['x1', '{0}'])
}

hexout = ""

def decode_pseudo(pseudo_code, operands):
    temp_line = ""
    new_op, template = pseudo_map[pseudo_code]
    temp_line += new_op + " "
    if template:
        for part in template:
            if part.startswith("{"):

                temp_line += operands[int(part[1])] + ", "
            else:
                temp_line += part + ", "
            ret_line = temp_line.rstrip(", ")

    return ret_line + "\n"    




with open(os.path.join(SCRIPT_DIR, 'assembly.txt'), 'r') as file:

    pseudo_content = file.readlines()
    print_line = ""
    content = []
    for line in pseudo_content:
        stripped = line.strip().split('#')[0]
        if stripped and not stripped.endswith(":"):
            instr = stripped.split(" ", 1)[0]
            try: 
                operands = [item.strip() for item in stripped.split(" ", 1)[1].split(",")]
            except IndexError:
                operands = []
            if instr in pseudo_map:
                new_cont = decode_pseudo(instr, operands)
                content.append(new_cont)
            else:
                content.append(line)
        else:
            content.append(line)



    for line in content:
        print(line.strip())





    hexline = 0

    labels = {}
    count = 0
    for line in content:
        stripped = line.strip().split("#")[0]
        if stripped.endswith(':'):

            labels[stripped[:-1]] = count
        elif stripped and not stripped.startswith('#'):
            count += 4




    count = 0
    for index, line in enumerate(content):
        line = line.split("#")[0]
        tokens =  line.split(None, 1)
        
        valid_instr = True
        if len(tokens) == 1 and tokens[0].strip().endswith(':'):
            continue
        if len(tokens) == 2: #if has an instr and params
            try: 
                entry = my_map[tokens[0].strip()]
                opcode = (entry[0])

                if opcode != 0b0000011 and opcode != 0b0100011:
                    params = tokens[1].split(',')
                else:
                    params = [p.strip("x )\n") for p in re.split(r'[,(]', tokens[1])]
           
                    

            except KeyError:
                print(f"malformed instruction, key not in values at {index}")
                valid_instr = False
                continue

            if opcode == 0b0110011 and len(params) == 3: #for R type if has the right number params
                
                funct3 = entry[1]
                funct7 = entry[2]
                rd = int(params[0].strip("x "))
                rs1 = int(params[1].strip("x "))
                rs2 = int(params[2].strip("x "))


                intline =  funct7 << 25 |  rs2  << 20 | rs1 << 15 | funct3 << 12| rd << 7 | opcode
                

            elif opcode == 0b0110011:
                print(f"Invalid R type instruction in line {index}")
                valid_instr = False

            elif opcode == 0b0010011 and len(params) == 3: #I type

                funct3 = entry[1]
                rd = int(params[0].strip("x "))
                rs1 = int(params[1].strip("x "))
                try:
                     immparam = int(params[2].strip()) & 0xFFF
                except ValueError:
                        immparam = (labels[params[2].strip()] - (count - 4)) & 0xFFF
                if funct3 == 0x1 or funct3 == 0x5:
                    if(immparam > 31):
                        print("immediate is too large for shift, will be truncated")

                    imm = entry[2] << 5 | immparam

                else:
                    imm = immparam
                
                intline = imm << 20 | rs1 << 15 | funct3 << 12 | rd << 7 | opcode


            elif opcode == 0b0010011:
                print(f"Invalid I type instruction in line {index}")
                valid_instr = False
            
            elif opcode == 0b0000011 and len(params) == 3: #loads
                
                funct3 = entry[1]
                rd = int(params[0])
                rs1 = int(params[2])
                imm = int(params[1]) & 0xFFF

                intline = imm << 20 | rs1 << 15 | funct3 << 12 | rd << 7 | opcode

            elif opcode == 0b0000011:
                print(f"invalid Load instruction in line {index}")
                valid_instr = False 

            elif opcode == 0b0100011 and len(params) == 3: #saves

                funct3 = entry[1]
                rs2 = int(params[0])
                rs1 = int(params[2])
                imm = int(params[1]) & 0xFFF

                intline =  ((imm >> 5) & 0x7F) << 25 | rs2 << 20 |  rs1 << 15 | funct3 << 12 | (imm & 0x1F) << 7  | opcode

            elif opcode == 0b0100011:
                print(f"invalid save instruction in line {index}")
                valid_instr = False

            elif opcode == 0b1100011 and len(params) == 3: #branch

                funct3 = entry[1]
                rs1 = int(params[0].strip("x "))
                rs2 = int(params[1].strip("x "))
                try:
                    imm = int(params[2]) & 0x1FFF
                except ValueError:
                    imm = (labels[params[2].strip()] - count) & 0x1FFF

                intline = (imm >> 12) << 31| ((imm >> 5) & 0x3F)  << 25 | rs2 << 20 | rs1 << 15 | funct3 << 12 |  ((imm >> 1) & 0xF) << 8 | ((imm >> 11) & 0x1) << 7 | opcode  

            elif opcode == 0b1100011:
                print(f"invalid Branch instruction in line {index}")
                valid_instr = False

            elif opcode == 0b1101111 and len(params) == 2: #jal

                rd = int(params[0].strip("x "))
                try:
                    imm = int(params[1]) & 0x1FFFFF
                except ValueError:
                    imm = (labels[params[1].strip()] - count) & 0x1FFFFF

                intline = (imm >> 20) << 31 | ((imm >> 1) & 0x3FF) << 21 | ((imm >> 11) & 0x1) << 20 | ((imm >> 12) & 0xFF) << 12 | rd << 7 | opcode


            elif opcode == 0b1101111 and len(params) == 1: #jal shorthand
                rd = 1
                imm = (labels[params[0].strip()] - count) & 0x1FFFFF

                intline = (imm >> 20) << 31 | ((imm >> 1) & 0x3FF) << 21 | ((imm >> 11) & 0x1) << 20 | ((imm >> 12) & 0xFF) << 12 | rd << 7 | opcode

            elif opcode == 0b1101111:
                print(f"invalid jump instruction on line {index}")
                valid_instr = False


            
            elif opcode in (0b0110111, 0b0010111) and len(params) == 2: #lui, auipc
                rd = int(params[0].strip("x "))
                imm = int(params[1].strip(), 16) if '0x' in params[1] else int(params[1].strip())
                imm = imm & 0xFFFFF
                
                intline = (imm << 12) | (rd << 7) | opcode

            elif opcode == 0b1100111 and len(params) == 3: # jalr
                funct3 = entry[1]
                rd = int(params[0].strip("x "))
                rs1 = int(params[1].strip("x "))
                imm = int(params[2].strip()) & 0xFFF
                
                intline = (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

            elif opcode == 0b1100111 and len(params) == 1: #jalr shortcut
                funct3 = entry[1]
                rd = 1
                rs1 = int(params[0].strip("x "))
                imm = 0
                
                intline = (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode


            else:
                print(f"Unhandled instruction or missing opcode handler on line {index}: {tokens[0]}")
                valid_instr = False

            if valid_instr:
                hexline = hex(intline)[2:]

                while(len(hexline) < 8):
                    hexline = "0" + hexline

                hexout += hexline + '\n'   
                count += 4
            else:
                continue    
            
            
        elif not line.strip():
            continue
        else:
            print(f"invalid instruction format, needs param or operation in line {index}")

with open(os.path.join(SCRIPT_DIR, 'instmemp.hex'), 'w') as file:
    file.write((hexout))

            
