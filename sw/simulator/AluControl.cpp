#include "InstDecoder.hpp"
#include <cstdint>

enum class AluType : uint8_t{
    ALU_add, ALU_sub, ALU_xor, ALU_or, ALU_and, ALU_sll, ALU_srl, ALU_sra, ALU_slt, ALU_sltu, Invalid
};

AluType runAluControl(DecodedInstr d, uint32_t instr)
{
    AluType sel = AluType::Invalid;
    switch(d.opcode)
    {
        case 0b0110011:
        {
            switch(d.funct3)
            {
                case 0x0:
                {
                    if(d.funct7 == 0x00){
                        sel = AluType::ALU_add;
                    }
                    else{
                        sel = AluType::ALU_sub;
                    }
                    break;
                }
                case 0x4:{
                    sel = AluType::ALU_xor;
                    break;
                }
                case 0x6:{
                    sel = AluType::ALU_or;
                    break;
                }
                case 0x7:{
                    sel = AluType::ALU_and;
                    break;
                }
                case 0x1:{
                    sel = AluType::ALU_sll;
                    break;
                }
                case 0x5:
                {
                    if(d.funct7 == 0x00){
                        sel = AluType::ALU_srl;
                    }
                    else{
                        sel = AluType::ALU_sra;
                    }
                    break;
                }
                case 0x2:
                {
                    sel = AluType::ALU_slt;
                    break;
                }
                case 0x3:
                {
                    sel = AluType::ALU_sltu;
                    break;
                }

            }
        }
        case 0b0010011:
        {
            switch(d.funct3)
            {
                case 0x0:{
                    sel = AluType::ALU_add;
                    break;
                }
                case 0x4:{
                    sel = AluType::ALU_xor;
                    break;
                }
                case 0x6:{
                    sel = AluType::ALU_or;
                    break;
                }
                case 0x7:{
                    sel = AluType::ALU_and;
                }
                case 0x1:{
                    sel = AluType::ALU_sll;
                }
                case 0x5:{
                    if(((instr >> 5) & 0x7f) == 0x00){
                        sel = AluType::ALU_srl;
                    }
                    else{
                        sel = AluType::ALU_sra;
                    }
                }
                case 0x2:{
                    sel = AluType::ALU_slt;
                }
                case 0x3:{
                    sel = AluType::ALU_sltu;
                }
                
            }
        }
        case 0b0000011:
        {
            sel = AluType::ALU_add;
        }
        case 0b0100011:
        {
            sel = AluType::ALU_add;
        }
        case 0b1100011:{
            sel = AluType::ALU_sub;
        }
        case 0b1101111:{
            sel = AluType::ALU_add;
        }
        case 0b1100111:
        {
            sel = AluType::ALU_add;
        }
        case 0b0110111:{
            sel = AluType::ALU_add;
        }
        case 0b0010111:{
            sel = AluType::ALU_add;
        }
    }
    return sel;
}