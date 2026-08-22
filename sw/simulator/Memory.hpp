#pragma once
#include <cstdint>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include "Control.hpp"
#include "InstDecoder.hpp"


struct CpuState{
    uint32_t pc = 0;
    uint32_t regs[32] = {0};
    uint32_t imem[256] = {0};
    uint32_t dmem[256] = {0};
    bool halted = false;
};

void readHexFile(const std::string& filename, CpuState& cs);

int32_t readMem(CpuState& cu, ControlSignal cs, DecodedInstr d, uint32_t addr);

void writeMem(CpuState& state, ControlSignal cs, DecodedInstr d, uint32_t data, uint32_t addr);

void writeReg(CpuState& state, ControlSignal cs, DecodedInstr d, uint32_t data);