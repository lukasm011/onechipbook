import subprocess
import re
import argparse

TEST_SIM = "/home/lukas/digital/onechipbook/sim/test_sw/build/test_sim.elf"
TESTBENCH = "/home/lukas/digital/onechipbook/sim/cpu/obj_dir/Vcpu_tb"
CMD_FILE = "/home/lukas/digital/onechipbook/sim/test_sw/build/spike_cmds.txt"
# CL Arguments
parser = argparse.ArgumentParser()
parser.add_argument('-hex', action="store")
parser.add_argument('-debug', action="store_true")
parser.add_argument('-memsize', action="store", dest='memsize')
parser.add_argument('-startaddr', action="store", dest='startaddr')
args=parser.parse_args()

ABI_TO_X = {
    "zero": 0, "ra": 1, "sp": 2, "gp": 3, "tp": 4,
    "t0": 5, "t1": 6, "t2": 7,
    "s0": 8, "s1": 9,
    "a0": 10, "a1": 11, "a2": 12, "a3": 13,
    "a4": 14, "a5": 15, "a6": 16, "a7": 17,
    "s2": 18, "s3": 19, "s4": 20, "s5": 21, "s6": 22,
    "s7": 23, "s8": 24, "s9": 25, "s10": 26, "s11": 27,
    "t3": 28, "t4": 29, "t5": 30, "t6": 31,
}


#Find program size
program_size = int(subprocess.run(["riscv64-unknown-elf-size", TEST_SIM], capture_output=True).stdout.decode('ASCII').split()[6])

#Write spike commands
with open(CMD_FILE, "w") as cmd:
	cmd.write(f"until pc 0 {hex(program_size-4+0x4000)}\nreg 0\nquit\n")

if(args.debug):
	print(f"PROGSIZE: {program_size}")

golden_model_proc = subprocess.run(["spike", "-d", "--isa=rv32i", "-l", "--log-commits", f"-m0x4000:{args.memsize if args.memsize else program_size}", f"--debug-cmd={CMD_FILE}", f"{TEST_SIM}"], capture_output=True)

golden_model = dict((re.findall("([a-z0-9]+): (0x[0-9a-f]{8})", golden_model_proc.stderr.decode('ASCII'))))

#Convert register names to numbers
for r in golden_model:
	r = ABI_TO_X.get(r)

golden_model = {ABI_TO_X.get(r): golden_model.get(r) for r in golden_model}

if(args.debug):
	print(args.hex)
real_model_proc = subprocess.run([TESTBENCH, f"+PROGSIZE={program_size}", f"+HEX_FILE={args.hex}"], capture_output=True)

real_model = dict((re.findall("([0-9]+): ([0-9a-f]{8})", real_model_proc.stdout.decode('ASCII'))))

real_model = {int(r): real_model.get(r) for r in real_model}

#Parse logs
real_model_log = re.findall("([0-9]+) : ([0-9a-f]{8})", real_model_proc.stdout.decode('ASCII'))
golden_model_log = re.findall("x([0-9a-f]{8}) .*? x([0-9]+) +0x([0-9a-f]{8})", golden_model_proc.stderr.decode('ASCII'))

if(args.debug):
	print(f"DEBUG REAL {real_model_log}\n")
	print(f"DEBUG GOLDEN {golden_model_log}\n")

offset = 0
while(int(golden_model_log[offset][0], 16) != int(args.startaddr, 0)):
	offset+=1

#Compare outputs
test = True
for i in range(len(real_model_log)):
	if(golden_model_log[offset+i][2] != real_model_log[i][1]):
		print(f"==========================\nError at instruction {i}.\nShould be {golden_model_log[offset+i][2]} is {real_model_log[i][1]}.\nRegister {real_model_log[i][0]}\nInstruction at addr {golden_model_log[offset+i][0]}")
		test = False
	if(golden_model_log[offset+i][1] != real_model_log[i][0]):
		#Check allignment, test outputs need to be revised if wrong. Does not imply non-matching registers
		print(f"Registers do not lign up at {offset+i}.\nExpected {golden_model_log[offset+i][1]}.\nGot{real_model_log[i][0]}.")
print("==========================")

for i in range(1, 32):
	if((int(golden_model.get(i), 16) != int("0x"+str(real_model.get(i)), 16))):
		print(f"\033[0mTest failed! Register {i} is {real_model.get(i)}, should be {golden_model.get(i)}\033[0m")
		test = False
if(test):
	print("\033[92mTest passed!\033[0m")
else:
	printf("\033[91mTest failed!\033[0m")