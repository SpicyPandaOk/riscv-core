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

