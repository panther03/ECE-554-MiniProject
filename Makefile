ASM_PROG ?= "BasicOpCodes1.asm"
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
	@perl $(SW_DIR)/asmbl.pl $(FW_DIR)/$(ASM_PROG) > $(OUT_DIR)/out.hex

fpga: $(OUT_DIR) fw
	@make -C $(FPGA_DIR)/$(FPGA_DEV)

sim:
	@python3 sim.py