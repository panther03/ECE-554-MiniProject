PROJ=MiniProject
REVISION=MiniLab

ifneq ($(QUARTUS_13_BIN),)
Q13PFX=$(QUARTUS_13_BIN)/
else
endif

all: compile
	@cp output_files/$(REVISION).sof ../../out/out.sof

compile:
	$(Q13PFX)quartus_sh --flow compile $(PROJ) -c $(REVISION)

update_mem:
	$(Q13PFX)quartus_cdb --update_mif $(PROJ) --rev=$(REVISION)
	$(Q13PFX)quartus_asm $(PROJ) --rev=$(REVISION)