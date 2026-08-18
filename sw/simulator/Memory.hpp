#pragma once
#include <cstdint>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>

struct CpuState{
    uint32_t pc = 0;
    uint32_t regs[32] = {0};
    uint32_t imem[256] = {0};
    uint32_t dmem[256] = {0};
    bool halted = false;
};

void readHexFile(const std::string& filename, CpuState& cs);
