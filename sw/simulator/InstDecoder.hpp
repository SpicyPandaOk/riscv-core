#pragma once
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

DecodedInstr decode(uint32_t instr);