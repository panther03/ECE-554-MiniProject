ASM_PROG ?= "HelloWorld.asm"
FPGA_DEV ?= "de1_soc"
TB ?= "" # no default

# trying to save you from silly capitalization mistakes
ifneq ($(tb),)
	TB = $(tb)
endif

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

fpga_fw: $(OUT_DIR) fw
	@make -C $(FPGA_DIR)/$(FPGA_DEV) update_mem

fpga: $(OUT_DIR) fw
	@make -C $(FPGA_DIR)/$(FPGA_DEV)

sim:
ifeq ($(TB),)
	@python3 $(SW_DIR)/sim.py test
else
	@python3 $(SW_DIR)/sim.py test $(TB)
endif

gui:
ifeq ($(TB),)
	@python3 $(SW_DIR)/sim.py gui
else
	@python3 $(SW_DIR)/sim.py gui $(TB)
endif

proj:
ifeq ($(TB),)
	@python3 $(SW_DIR)/sim.py proj
else
	@python3 $(SW_DIR)/sim.py proj $(TB)
endif

clean:
ifeq ($(TB),)
	@python3 $(SW_DIR)/sim.py clean
else
	@python3 $(SW_DIR)/sim.py clean $(TB)
endif