SIM_DIR  = sim
FILELIST = files.f

.PHONY: all icarus wave clean

all: icarus

icarus:
	mkdir -p $(SIM_DIR)
	iverilog -g2012 -I./rtl -o $(SIM_DIR)/sim.out -f $(FILELIST)
	vvp $(SIM_DIR)/sim.out

wave:
	gtkwave $(SIM_DIR)/dump.vcd &

clean:
	rm -rf $(SIM_DIR)
