SIM_DIR  = sim
FILELIST_TEST = filestest.f
FILELIST_RUN = filesrun.f
ASSEMBLER = ../sw/assembler.py

TEST_PROGRAM = ../sw/testassembly.txt
PROGRAM ?= ../sw/assembly.txt

.PHONY: all icarus wave clean

all: icarus

assemble-run:
	python3 $(ASSEMBLER) $(PROGRAM)
assemble-test:
	python3 $(ASSEMBLER) $(TEST_PROGRAM)
test: assemble-test
	mkdir -p $(SIM_DIR)
	iverilog -g2012 -I../tb -I../rtl -o $(SIM_DIR)/test.out -f $(FILELIST_TEST)
	vvp $(SIM_DIR)/test.out
run: assemble-run
	mkdir -p $(SIM_DIR)
	iverilog -g2012 -I../tb -I../rtl -o $(SIM_DIR)/run.out -f $(FILELIST_RUN)
	vvp $(SIM_DIR)/run.out

wave:
	gtkwave $(SIM_DIR)/dump.vcd &

clean:
	rm -rf $(SIM_DIR)
