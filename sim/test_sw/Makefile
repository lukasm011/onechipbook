.PHONY: clean
BUILD_DIR := build/
ASM_SRCS := assembly1.s
ASM_OBJS := $(patsubst %.s, $(BUILD_DIR)%.o, $(ASM_SRCS))
PY_PATH := ~/venvs/cocotb-venv/bin/python3
DUT_PATH := /home/lukas/digital/onechipbook/sim/cpu/
HEX_PATH := /home/lukas/digital/onechipbook/sim/test_sw/build/test.hex
MEMSIZE := 20000


test_final: test.hex test_sim.elf
	$(MAKE) -C $(DUT_PATH) clean
	$(MAKE) -C $(DUT_PATH)
	$(PY_PATH) test_scripts/test_script.py -hex="$(HEX_PATH)" -memsize=$(MEMSIZE) -startaddr=0x4000

test.hex: test.elf
	riscv64-unknown-elf-objcopy -O binary $(BUILD_DIR)$< $(BUILD_DIR)test.bin
	$(PY_PATH) firmwarehexer.py --input $(BUILD_DIR)test.bin --output $(BUILD_DIR)test.hex --startaddr 0x0

test_sim.elf: $(ASM_OBJS)
	riscv64-unknown-elf-ld --no-relax -m elf32lriscv -T script_sim.lds -o $(BUILD_DIR)$@ $^

test.elf: $(ASM_OBJS)
	riscv64-unknown-elf-ld --no-relax -m elf32lriscv -T script.lds -o $(BUILD_DIR)$@ $^

$(ASM_OBJS): $(BUILD_DIR)%.o : $(BUILD_DIR)%.s
	mkdir -p $(BUILD_DIR)
	riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o $@ $<

clean:
	rm -rf $(ASM_OBJS) $(addprefix $(BUILD_DIR)test, .hex .bin .elf)
	rm -if $(ASM_OBJS) $(addprefix $(BUILD_DIR)test_sim, .elf)
