PROJ=MiniProject
REVISION=MiniLab

ifneq ($(QUARTUS_BIN),)
QPFX=$(QUARTUS_BIN)/
endif

all: compile
	cp output_files/$(REVISION).sof ../../out/out.sof

compile:
	$(QPFX)quartus_sh --flow compile $(PROJ) -c $(REVISION)

update_mem:
	$(QPFX)quartus_cdb --update_mif $(PROJ) --rev=$(REVISION)
	$(QPFX)quartus_asm $(PROJ) --rev=$(REVISION)