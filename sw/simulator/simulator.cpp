#include <cstdint>
#include <vector>
#include "InstDecoder.hpp"
#include "Control.hpp"
#include "AluControl.hpp"
#include "Alu.hpp"
#include "Memory.hpp"
#include <iostream>

int main(){
    std::vector<int> instructions;
    instructions.push_back(25);
    for(int i = 0; i < instructions.size(); i++)
    {
        DecodedInstr test = decode(instructions[i]);
        std::cout << "opcode: " << int(test.opcode); 
    }

}
