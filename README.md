# Overview
### RV32I CPU with 5 stage pipeline, made in largely verilog with occasional system verilog features. implements the base instruction set for RISC V with no expansions currently

## pipelining
Instruction Find (IF) -> Instruction decode (ID) -> Execute (EX) -> Memory (MEM) -> Write back (WB)
branches get resolved in EX, forwarding comes from EX_MEM and MEM_WB

# repo layout
## docs 
includes the makefile and the file list for use in compiling with icarus verilog, as well as an overview of the architecture

## rtl
folder with all of the rtl itself in system verilog files

## sw
Python assembler with a testbench paired assembly file as well as several functional programs
## tb
the test suite tb.sv along with a tb for running programs


# running
made with icarus verilog in mind 
## icarus -V:
Icarus Verilog version 12.0 (stable) ()

Copyright (c) 2000-2021 Stephen Williams (steve@icarus.com)

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

Icarus Verilog Preprocessor version 12.0 (stable) ()

Copyright (c) 1999-2021 Stephen Williams (steve@icarus.com)

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

Icarus Verilog Parser/Elaborator version 12.0 (stable) ()

Copyright (c) 1998-2021 Stephen Williams (steve@icarus.com)

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

 FLAGS DLL vvp.tgt
vvp.tgt: Icarus Verilog VVP Code Generator 12.0 (stable) ()

Copyright (c) 2001-2021 Stephen Williams (steve@icarus.com)

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

### compile and run with either "make test" for test suite or "make run" to run a program. to choose a file use "make run PROGRAM=../sw/{file_name}"

# testing
### uses a series of tests to run through different capabilities of the cpu with a task feature to show quickly what areas are not functioning if bugs present

# limitations
### no advanced memory options such as cache etc, only 256 program memory size. No branch prediction and only 1  KB of datamem
