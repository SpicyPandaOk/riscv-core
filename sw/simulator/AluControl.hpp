#pragma once
#include "InstDecoder.hpp"
#include <cstdint>

enum class AluType : uint8_t{
    ALU_add, ALU_sub, ALU_xor, ALU_or, ALU_and, ALU_sll, ALU_srl, ALU_sra, ALU_slt, ALU_sltu, Invalid
};

AluType runAluControl(DecodedInstr d, uint32_t instr);