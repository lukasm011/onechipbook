.PHONY: clean
BUILD_DIR := build/
ASM_SRCS := r_type.asm
ASM_OBJS := $(patsubst %.asm, $(BUILD_DIR)%.o, $(ASM_SRCS))
PY_PATH := ~/venvs/cocotb-venv/bin/python3

test.hex: test.elf
	riscv64-unknown-elf-objcopy -O binary $(BUILD_DIR)$< $(BUILD_DIR)test.bin
	$(PY_PATH) firmwarehexer.py --input $(BUILD_DIR)test.bin --output $(BUILD_DIR)test.hex --startaddr 0x0

test.elf: $(ASM_OBJS)
	riscv64-unknown-elf-ld --no-relax -m elf32lriscv -T script.lds -o $(BUILD_DIR)$@ $^

$(ASM_OBJS): $(BUILD_DIR)%.o : %.asm
	mkdir -p $(BUILD_DIR)
	riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o $@ $<

clean:
	rm -rf $(ASM_OBJS) $(addprefix $(BUILD_DIR)test, .hex .bin .elf)
