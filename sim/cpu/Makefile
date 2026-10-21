.PHONY: clean
CPU_SRCS := $(addprefix ../../rtl/cpu/, ../buspkgs.sv alu.sv regfile.sv controller.sv datapath.sv top/cpu_top.sv)

sim: #$(CPU_SRCS)
	verilator --binary --trace-fst -Wall -Wno-fatal --top-module cpu_tb $(CPU_SRCS) ../dummy_mem.sv cpu_tb.sv 
	./obj_dir/Vcpu_tb

clean:
	rm -rf obj_dir/*