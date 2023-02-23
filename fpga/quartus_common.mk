all: prog
	@cp output_files/$(REVISION).sof ../../out/out.sof
#	@cp output_files/$(REVISION).pof ../../out/out.pof

prog: compile
ifdef HPS_SOC
	@$(QPFX)quartus_pgm -mjtag -o "p;output_files/$(REVISION).sof@2"
else
	@$(QPFX)quartus_pgm -mjtag -o "p;output_files/$(REVISION).sof"
endif

compile:
	@$(QPFX)quartus_sh --flow compile $(PROJ) -c $(REVISION)

update_mem:
	@$(QPFX)quartus_cdb --update_mif $(PROJ) --rev=$(REVISION)
	@$(QPFX)quartus_asm $(PROJ) --rev=$(REVISION)