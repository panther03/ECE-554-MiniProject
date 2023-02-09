ASM_PROG ?= "mmioLoop.asm"
FPGA_DEV ?= "de1_soc"
TB ?= "" # no default

FW_DIR = "fw/"
SW_DIR = "sw/"
FPGA_DIR = "fpga/"
TB_DIR = "tb/"
OUT_DIR = "out/"

all: fpga

$(OUT_DIR):
	@mkdir -p $(OUT_DIR)

fw: $(OUT_DIR)
	@python3 $(SW_DIR)/assemble.py $(FW_DIR)/$(ASM_PROG) -o $(OUT_DIR)/out.hex

fpga: $(OUT_DIR) fw
	@make -C $(FPGA_DIR)/$(FPGA_DEV)

sim:
	ifeq ($(TB),)
	@python3 $(SW_DIR)/sim.py test
	else
	@python3 $(SW_DIR)/sim.py test $(TB)
	endif

sim_gui:
	ifeq ($(TB),)
	@python3 $(SW_DIR)/sim.py gui
	else
	@python3 $(SW_DIR)/sim.py gui $(TB)
	endif

sim_proj:
	ifeq ($(TB),)
	@python3 $(SW_DIR)/sim.py proj
	else
	@python3 $(SW_DIR)/sim.py proj $(TB)
	endif