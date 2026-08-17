#pragma once
#include "InstDecoder.hpp"
#include <cstdint>

struct ControlSignal{
    bool regWrite = 0;
    bool dataWrite = 0;
    bool dataRead = 0;
    bool memToReg = 0;
    bool aluSrc = 0;
    bool branch = 0;
    bool jump = 0;
    bool jalr = 0;
};

ControlSignal runControl(DecodedInstr d);