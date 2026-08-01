SIM_DIR  = sim
FILELIST = files.f
ASSEMBLER = ../sw/assembler.py

.PHONY: all icarus wave clean

all: icarus

assemble:
	python3 $(ASSEMBLER)

icarus: assemble
	mkdir -p $(SIM_DIR)
	iverilog -g2012 -I../tb -I../rtl -o $(SIM_DIR)/sim.out -f $(FILELIST)
	vvp $(SIM_DIR)/sim.out

wave:
	gtkwave $(SIM_DIR)/dump.vcd &

clean:
	rm -rf $(SIM_DIR)
