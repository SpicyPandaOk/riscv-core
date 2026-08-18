#include <cstdint>
#include "AluControl.hpp"
#include "InstDecoder.hpp"

struct AluOut{
    int32_t result = 0;
    bool overflow = 0;
    bool negative = 0;
    bool zero = 0;
};

AluOut runAlu(AluType sel, int32_t r1, int32_t r2){
    AluOut a;


    uint32_t u1 = static_cast<uint32_t>(r1);
    uint32_t u2 = static_cast<uint32_t>(r2);

    uint32_t addOut = u1 + u2;
    uint32_t subOut = u1 - u2;
    int32_t xorOut = (r1 ^ r2);
    int32_t orOut = (r1 | r2);
    int32_t andOut = (r1 & r2);
    uint32_t sllOut = (u1 << (r2 & 0x1f));
    uint32_t srlOut = (static_cast<uint32_t>(r1) >> (r2 & 0x1f));
    int32_t sraOut = (r1 >> (r2 & 0x1f));
    int32_t sltOut = (r1 < r2);
    int32_t sltuOut = (static_cast<uint32_t>(r1) < static_cast<uint32_t>(r2));

    switch(sel)
    {
        case AluType::ALU_add:{
            a.result = static_cast<int32_t>(addOut);
            break;
        }
        case AluType::ALU_sub:{
            a.result = static_cast<int32_t>(subOut);
            break;
        }
        case AluType::ALU_xor:{
            a.result = xorOut;
            break;
        }
        case AluType::ALU_or:{
            a.result = orOut;
            break;
        }
        case AluType::ALU_and:{
            a.result = andOut;
            break;
        }
        case AluType::ALU_sll:{
            a.result = static_cast<int32_t>(sllOut);
            break;

        }
        case AluType::ALU_srl:{
            a.result = static_cast<int32_t>(srlOut);
            break;
        }
        case AluType::ALU_sra:{
            a.result = sraOut;
            break;
        }
        case AluType::ALU_slt:{
            a.result = sltOut;
            break;
        }
        case AluType::ALU_sltu:{
            a.result = sltuOut;
            break;
        }
        case AluType::Invalid:{
            a.result = static_cast<int32_t>(addOut);
        }


    }
    return a;
}