#include <cstdint>




enum class InstType : uint8_t{
    R_type, I_type, S_type, B_type, U_type, J_type, Invalid
};


struct DecodedInstr {
    uint8_t opcode = 0;
    uint8_t funct3 = 0;
    uint8_t funct7 = 0;
    uint8_t rs1 = 0;
    uint8_t rs2 = 0;
    uint8_t rd = 0;
    int32_t imm =0;
    InstType inst_type = InstType::Invalid;
};

DecodedInstr decode(uint32_t instr)
{
    DecodedInstr d;
    d.opcode = instr & 0x7F;

    switch(d.opcode)
    {
        //R_type decode
        case 0b0110011:{
            d.funct7 = (instr >> 25) & 0x7F; 
            d.rs2 = (instr >> 20) & 0x1F;
            d.rs1 = (instr >> 15) & 0x1f;
            d.funct3 = (instr >> 12) & 0x7;
            d.rd = (instr >> 7) & 0x1f;
            d.inst_type = InstType::R_type;
            break;
        }
        // I_type 
        case 0b0010011:
        case 0b0000011:
        case 0b1100111:
        {
            d.imm = (static_cast<int32_t>(instr) >> 20);
            d.rs1 = (instr >> 15) & 0x1f;
            d.funct3 = (instr >> 12) & 0x7;
            d.rd = (instr >> 7) & 0x1f;
            d.inst_type = InstType::I_type;
            break;
        }
        //S_type
        case 0b0100011:
        {
            d.imm += ((instr >> 25) & 0x7f) <<5;
            d.rs2 = (instr >> 20) & 0x1f;
            d.rs1 = (instr >> 15) & 0x1f;
            d.funct3 = (instr >> 12) & 0x7;
            d.imm += (instr >> 7) & 0x1f;
            d.inst_type = InstType::S_type;
            d.imm += (static_cast<int32_t>(instr) >>31) << 12;
            break;
        }
        //B_type
        case 0b1100011:
        {
            d.imm += ((instr >> 31) & 0x1) << 12;
            d.imm += ((instr >> 25) & 0x3f) << 5;
            d.rs2 = (instr >> 20) & 0x1f;
            d.rs1 = (instr >> 15) & 0x1f;
            d.funct3 = (instr >> 12) & 0x7;
            d.imm += ((instr >> 8) & 0xf) << 1;
            d.imm += ((instr >> 7) & 0x1) << 11;
            d.inst_type = InstType::B_type;
            d.imm += ((static_cast<int32_t>(instr) >> 31) <<13);
            break;

        }
        //U_type
        case 0b0110111:
        case 0b0010111:
        {
            d.imm =((instr >> 12) & 0xFFFFF) << 12;
            d.rd = (instr >> 7) & 0x1f;
            d.inst_type = InstType::U_type;
            break;
        }
        //J_type
        case 0b1101111: 
        {
            d.imm += ((instr >> 31) & 0x1) <<20;
            d.imm += ((instr >> 21) & 0x3ff) << 1;
            d.imm += ((instr >> 20) & 0x1) << 11;
            d.imm += ((instr >> 12) & 0xff)  << 12;
            d.rd = (instr >> 7) & 0x1f;
            d.inst_type = InstType::J_type;
            d.imm += (static_cast<int32_t>(instr) >>31) << 21;
            break;
        }   

    }
    return d;
}       