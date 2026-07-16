BUILD_DIR = build
SIM_DIR = simulation
SIMPLE_SIM_DIR = $(SIM_DIR)/simple
POST_SYNTH_SIM_DIR = $(SIM_DIR)/post_synth
TESTBENCH_DIR = test_benches
BUILDING_BLOCKS_DIR = ../../../raw_implementation/building_blocks
ECP5_SIM_CELLS=$(shell yosys-config --datdir/ecp5/cells_sim.v)

VRAM_DIR = ../VRAM_ASM
planes_cache_DIR = ../planes_cache_ASM
row_cache_DIR = ../row_cache_ASM

DESIGN = memory_management
TOP = memory_management
TARGET = memory_management
OBJS = $(wildcard *.v) $(wildcard $(BUILDING_BLOCKS_DIR)/*.v)
OBJS += $(wildcard $(VRAM_DIR)/*.v)
OBJS += $(wildcard $(planes_cache_DIR)/*.v)
OBJS += $(wildcard $(row_cache_DIR)/*.v)
post_synth_OBJS = $(wildcard $(VRAM_DIR)/build/*_synth.v) $(wildcard $(planes_cache_DIR)/build/*_synth.v)
.PHONY : all simple_sim re_simple_sim sim_post_synth re_sim_post_synth clean
all : simple_sim

simple_sim : $(SIMPLE_SIM_DIR) #Crea la carpeta, los archivos de simulación y lanza GTKwave
	iverilog -o $(SIMPLE_SIM_DIR)/$(TARGET)_TB.vvp -DBENCH -DSIM -DPASSTHROUGH_PLL -DBOARD_FREQ=27 -DCPU_FREQ=27 $(TESTBENCH_DIR)/$(TARGET)_TB.v $(OBJS)
	vvp $(SIMPLE_SIM_DIR)/$(TARGET)_TB.vvp
	mv $(TARGET)_TB.vcd $(SIMPLE_SIM_DIR)/
	gtkwave $(SIMPLE_SIM_DIR)/$(TARGET)_TB.vcd $(SIMPLE_SIM_DIR)/signals.gtkw &
re_simple_sim : $(SIMPLE_SIM_DIR) #Crea la carpeta y los archivos de simulación
	iverilog -o $(SIMPLE_SIM_DIR)/$(TARGET)_TB.vvp -DBENCH -DSIM -DPASSTHROUGH_PLL -DBOARD_FREQ=27 -DCPU_FREQ=27 $(TESTBENCH_DIR)/$(TARGET)_TB.v $(OBJS)
	vvp $(SIMPLE_SIM_DIR)/$(TARGET)_TB.vvp
	mv $(TARGET)_TB.vcd $(SIMPLE_SIM_DIR)/

sim_post_synth : build/$(TOP).json $(OBJS) $(POST_SYNTH_SIM_DIR)
	iverilog -o $(POST_SYNTH_SIM_DIR)/sim_post_synth_PS.vvp -s $(TOP)_TB $(TESTBENCH_DIR)/$(TARGET)_TB.v $(BUILD_DIR)/$(TOP)_synth.v $(post_synth_OBJS) $(ECP5_SIM_CELLS)
#	iverilog -o $@_PS.vpp                       -s $(TOP)_TB $(TARGET)_TB.v                  $(TOP)_synth.v              $(ECP5_SIM_CELLS) 
	vvp $(POST_SYNTH_SIM_DIR)/sim_post_synth_PS.vvp
	mv $(TOP)_TB.vcd $(POST_SYNTH_SIM_DIR)/
	gtkwave $(POST_SYNTH_SIM_DIR)/$(TOP)_TB.vcd $(POST_SYNTH_SIM_DIR)/signals.gtkw &
re_sim_post_synth : build/$(TOP).json $(OBJS) $(POST_SYNTH_SIM_DIR)
	iverilog -o $(POST_SYNTH_SIM_DIR)/sim_post_synth_PS.vvp -s $(TOP)_TB $(TESTBENCH_DIR)/$(TARGET)_TB.v $(BUILD_DIR)/$(TOP)_synth.v $(post_synth_OBJS) $(ECP5_SIM_CELLS)
	vvp $(POST_SYNTH_SIM_DIR)/sim_post_synth_PS.vvp
	mv $(TOP)_TB.vcd $(POST_SYNTH_SIM_DIR)/



#LATTICE COLORLIGHT 5A
$(BUILD_DIR)/$(TOP).json : $(BUILD_DIR)
	yosys -v3 -l $(BUILD_DIR)/synth.log -p 'attrmap -tocase keep -imap keep="true" keep=1; synth_ecp5 -top $(TOP) -json $(BUILD_DIR)/$(TOP).json; write_verilog -attr2comment $(BUILD_DIR)/$(TOP)_synth.v;' $(OBJS) -l $(BUILD_DIR)/$(TOP).rpt

$(SIMPLE_SIM_DIR) :
	mkdir -p $(SIMPLE_SIM_DIR)

$(POST_SYNTH_SIM_DIR) :
	mkdir -p $(POST_SYNTH_SIM_DIR)

$(BUILD_DIR) :
	mkdir -p $(BUILD_DIR)

clean :
	rm -rf $(BUILD_DIR)
	find $(SIMPLE_SIM_DIR) -depth -mindepth 1 ! -name "*.gtkw" -delete
	find $(POST_SYNTH_SIM_DIR) -depth -mindepth 1 ! -name "*.gtkw" -delete
