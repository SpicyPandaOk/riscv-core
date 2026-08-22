#include <cstdint>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>

#include "Control.hpp"
#include "InstDecoder.hpp"
#include "Alu.hpp"

struct CpuState{
    uint32_t pc = 0;
    uint32_t regs[32] = {0};
    uint32_t imem[256] = {0};
    uint32_t dmem[256] = {0};
    bool halted = false;
};

bool decBranch(CpuState& state, ControlSignal cs, DecodedInstr d, int32_t r1, int32_t r2){
    bool bt = false;
    if(cs.jump || cs.jalr){
        bt = true;
    }
    else if (cs.branch){
        switch(d.funct3){
            case 0x0:{
                bt = (r1 == r2);
                break;
            }
            case 0x1:{
                bt = (r1 != r2);
                break;
            }
            case 0x4:{
                bt = (r1 < r2);
                break;
            }
            case 0x5:{
                bt = (r1 >= r2);
                break;
            }
            case 0x6:{
                bt = (static_cast<uint32_t>(r1) < static_cast<uint32_t>(r2));
                break;
            }
            case 0x7:{
                bt = (static_cast<uint32_t>(r1) >= static_cast<uint32_t>(r2));
                break;
            }
        }
    }

    return bt;
}


void updatePc(CpuState& state, ControlSignal cs, uint32_t branchTarget, bool bt){
    if(bt){
        state.pc = branchTarget;
    }
    else{
        state.pc += 4;
    }
}

int32_t calcBtarget(CpuState& state, ControlSignal cs, AluOut ao, int32_t r1, DecodedInstr d){
    int32_t bTarget = 0;
    if(cs.jalr){
        bTarget = (d.imm + r1); 
    }
    else{
        bTarget = state.pc + d.imm;
    }
    return bTarget;
}

void readHexFile(const std::string& filename, CpuState& cs)
{
    std::ifstream file(filename);
    int current_size = 0;

    if(!file.is_open()){
        std::cerr << "Error could not open the file " << filename << std::endl;
    }

    std::string line;

    while(std::getline(file, line)){
        if(line.empty()) continue;

        try {
            if(current_size < 256)
            {
                uint32_t instruction = static_cast<uint32_t>(std::stoul(line,nullptr, 16 ));
                cs.imem[current_size] = instruction;
                current_size++;
            }
            
        }
        catch (const std::exception& e){
            std::cerr << "Warning: skipping invalid line \"" << line << "\". Error: " << e.what() << std::endl;
        }


    }

    file.close();
}

int32_t readMem(CpuState& cu, ControlSignal cs, DecodedInstr d, uint32_t addr){
    int32_t dataOut = 0;
    int32_t tempData = cu.dmem[(addr >> 2) & 0xFf ];
    if(cs.dataRead){
        switch(d.funct3){
            case 0x0:{
                switch(addr & 0x3){
                    case 0x0:{
                        dataOut = (tempData << 24) >> 24;
                        break;
                    }
                    case 0x1:{
                        dataOut = (tempData << 16) >> 24;
                        break;
                    }
                    case 0x2:
                    {
                        dataOut = (tempData << 8) >> 24;
                        break;
                    }
                    case 0x3:
                    {
                        dataOut = (tempData) >> 24;
                        break;
                    }

                }
                break;
            }
            case 0x1:{
                switch(addr & 0x1){
                    case 0x0:{
                        dataOut = (tempData << 16)>> 16;
                        break;
                    }
                    case 0x1:{
                        dataOut = (tempData)>>16;
                        break;
                    }

                }
                break;
            }   
            case 0x2:{
                dataOut = tempData;
                break;
            }
            case 0x4:{
                switch(addr & 0x3){
                    case 0x0:{
                        dataOut += tempData & 0xff;
                        break;
                    }
                    case 0x1:{
                        dataOut += (tempData >> 8) & 0xff;
                        break;
                    }
                    case 0x2:{
                        dataOut += (tempData >> 16) & 0xff;
                        break;
                    }
                    case 0x3:{
                        dataOut += (tempData >> 24) & 0xff;
                        break;
                    }
                    
                }
                break;
            }
            case 0x5:{
                switch(addr & 0x1){
                    case 0x0:{
                        dataOut += (tempData) & 0xffff;
                    }
                    case 0x1:{
                        dataOut += (tempData >> 16) & 0xffff;
                        break;
                    }
                }
                break;
            }
            
            
        }
    }
    return dataOut;
}


void writeMem(CpuState& state, ControlSignal cs, DecodedInstr d, uint32_t data, uint32_t addr){

    uint8_t shrtAddr = (addr >> 2);

    if(cs.dataWrite){
        switch(d.funct3){
            case 0x0:
            {
                switch(addr & 0x3){
                    case 0x0:{
                        state.dmem[shrtAddr] &= ~0xff;
                        state.dmem[shrtAddr] |= data & 0xff;
                        break;
                    }
                    case 0x1:{
                        state.dmem[shrtAddr] &= ~0xff00;
                        state.dmem[shrtAddr] |= data & 0xff;
                        break;
                    }
                    case 0x2:{
                        state.dmem[shrtAddr] &= ~0xff0000;
                        state.dmem[shrtAddr] |= data & 0xff;
                        break;
                    }
                    case 0x3:{
                        state.dmem[shrtAddr] &= ~0xff000000;
                        state.dmem[shrtAddr] |= data & 0xff;
                        break;
                    }
                }   
            break;         
            }
            case 0x1:{
                switch(addr & 0x1){
                    case 0x0:{
                        state.dmem[shrtAddr] &= ~0xffff;
                        state.dmem[shrtAddr] |= data & 0xffff;
                        break;
                    }
                    case 0x1:{
                        state.dmem[shrtAddr] &= ~0xffff0000;
                        state.dmem[shrtAddr] |= data &0xffff;
                        break;
                    }
                }
                break;
            }
            case 0x2:{
                state.dmem[shrtAddr] = data;
                break;
            }
        }
    }
}

void writeReg(CpuState& state, ControlSignal cs, DecodedInstr d, uint32_t data){
    if(cs.regWrite && d.rd != 0){
        state.regs[d.rd] = data;
    }
}