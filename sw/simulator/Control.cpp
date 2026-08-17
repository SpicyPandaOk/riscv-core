    #include "InstDecoder.hpp"
    #include <cstdint>

    struct ControlSignal
    {
        bool regWrite = 0;
        bool dataWrite = 0;
        bool dataRead = 0;
        bool memToReg = 0;
        bool aluSrc = 0;
        bool branch = 0;
        bool jump = 0;
        bool jalr = 0;
    };

    ControlSignal runControl(DecodedInstr d)
    {
        ControlSignal c;

        switch(d.opcode)
        {
            case 0b0110011:
            {
                c.regWrite = 1;
                break;
            }
            case 0b0010011:
            {
                c.regWrite = 1;
                c.aluSrc = 1;
                break;
            }
            case 0b0000011:
            {
                c.regWrite = 1;
                c.dataRead = 1;
                c.memToReg = 1;
                c.aluSrc = 1;
                break;
            }
            case 0b0100011:
            {
                c.dataWrite =1;
                c.aluSrc = 1;
                break;
            }
            case 0b1100011:
            {
                c.branch = 1;
                break;
            }

            case 0b1101111:
            {
                c.regWrite = 1;
                c.jump = 1;
                break;
            }

            case 0b1100111:
            {
                c.regWrite = 1;
                c.jump = 1;
                c.jalr = 1;
                c.aluSrc = 1;
                break;
            }
            case 0b0110111:
            case 0b0010111:
            {
                c.regWrite = 1;
                c.aluSrc = 1;
                break;
            }
        }
        return c;
    }
