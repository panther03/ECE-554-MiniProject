PROJ="MiniProject"
REVISION="MiniLab"

ifeq ($(QUARTUS_13_BIN),)
QUARTUS_SH="$(QUARTUS_13_BIN)/quartus_sh"
QUARTUS_PGM="$(QUARTUS_13_BIN)/quartus_pgm"
else
QUARTUS_SH="quartus_sh"
QUARTUS_PGM="quartus_pgm"
endif

all: compile
	@cp output_files/$(REVISION).sof ../../out/out.sof
	@cp output_files/$(REVISION).pof ../../out/out.pof

compile:
	$(QUARTUS_SH) --flow compile $(PROJ) -c $(REVISION)
