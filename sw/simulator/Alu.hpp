#pragma once
#include "AluControl.hpp"
#include "InstDecoder.hpp"

struct AluOut{
    int32_t result = 0;
    bool overflow = 0;
    bool negative = 0;
    bool zero = 0;

};

AluOut runAlu(AluType sel, int32_t r1, int32_t r2);