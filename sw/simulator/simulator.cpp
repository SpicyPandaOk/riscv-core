#include <cstdint>
#include <vector>
#include "InstDecoder.hpp"
#include <iostream>

int main(){
    std::vector<int> instructions;
    for(int i = 0; i < instructions.size(); i++)
    {
        DecodedInstr test = decode(instructions[i]);
        std::cout << "opcode: " << int(test.opcode); 
    }

}
