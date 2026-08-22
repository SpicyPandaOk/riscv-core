#include <cstdint>
#include <vector>
#include "InstDecoder.hpp"
#include "Control.hpp"
#include "AluControl.hpp"
#include "Alu.hpp"
#include "Memory.hpp"
#include <iostream>
#include "Cpu.hpp"
#include <string>


int main() {
    CpuState state;
    std::string outline = "";


    readHexFile("../sw/instmemp.hex", state);
    int haltCount = 0;
    uint32_t lastPc = 0;
    while(!state.halted){
        step(state);
        detectHalt(state, lastPc, haltCount);
        lastPc = state.pc;
    }

    for(int i = 0; i < 32; i++){
        outline += "Reg" + std::to_string(i) + ": " + std::to_string(state.regs[i]) + "\n";
    }

    std::cout << outline;
    std::cout << "HI";



}