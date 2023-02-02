PROJ="MiniProject0"
REVISION="MiniLab0"

all: compile
	cp output_files/$(REVISION).sof ../../out/out.sof
	cp output_files/$(REVISION).pof ../../out/out.pof

compile:
	quartus_sh --flow compile $(PROJ) -c $(REVISION)
