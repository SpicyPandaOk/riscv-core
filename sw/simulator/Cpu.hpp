#pragma once
#include <cstdint>
#include <vector>
#include "InstDecoder.hpp"
#include "Control.hpp"
#include "AluControl.hpp"
#include "Alu.hpp"
#include "Memory.hpp"
#include <iostream>

void step(CpuState state);
void detectHalt(CpuState state, uint32_t lastPc, int& haltCount);