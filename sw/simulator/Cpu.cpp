#include <cstdint>
#include <vector>
#include "InstDecoder.hpp"
#include "Control.hpp"
#include "AluControl.hpp"
#include "Alu.hpp"
#include "Memory.hpp"
#include <iostream>

void step(CpuState state)
{
    uint32_t instr = state.imem[state.pc >> 2];
    DecodedInstr d  = decode(instr);
    ControlSignal cs = runControl(d);
    AluType sel = runAluControl(d, instr);
    int32_t r1 = static_cast<int32_t>(state.regs[d.rs1]);
    int32_t r2 = static_cast<int32_t>(state.regs[d.rs2]);
    AluOut ao = runAlu(sel, r1, (cs.aluSrc) ? d.imm : r2 );
    int32_t memRes = readMem(state, cs, d, ao.result);
    writeMem(state, cs, d, r2, ao.result);
    writeReg(state,cs, d, (cs.memToReg ? memRes : ao.result));

}

void detectHalt(CpuState state, uint32_t lastPc, int& haltCount){

    if(state.pc == lastPc){
        haltCount++;
    }
    else{
        haltCount = 0;
    }

    state.halted = true;
}