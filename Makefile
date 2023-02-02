ASM_PROG ?= "" # TODO: add a default demo
FPGA_DEV ?= "de1_soc"

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
	@python3 sim.py