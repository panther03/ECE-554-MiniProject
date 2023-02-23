all: prog
	@cp output_files/$(REVISION).sof ../../out/out.sof
	@cp output_files/$(REVISION).pof ../../out/out.pof

prog: compile
	@$(QPFX)quartus_pgm -mjtag -o "p;output_files/$(REVISION).sof"

compile:
	@$(QPFX)quartus_sh --flow compile $(PROJ) -c $(REVISION)

update_mem:
	@$(QPFX)quartus_cdb --update_mif $(PROJ) --rev=$(REVISION)
	@$(QPFX)quartus_asm $(PROJ) --rev=$(REVISION)