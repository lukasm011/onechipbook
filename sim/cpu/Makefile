.PHONY: clean
CPU_SRCS := $(addprefix ../../rtl/cpu/, ../busifaces.sv alu.sv regfile.sv controller.sv datapath.sv top/cpu_top.sv)
VERILATOR_FLAGS := --binary --trace-fst -Wall -Wno-fatal
CAD_ENV := ~/oss-cad-suite/bin/

sim: #$(CPU_SRCS)
	$(CAD_ENV)verilator $(VERILATOR_FLAGS) --top-module cpu_tb $(CPU_SRCS) ../dummy_mem.sv cpu_tb.sv

clean:
	rm -rf obj_dir/*
