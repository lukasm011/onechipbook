.global _start
_start:
add x5, x0, x0
addi x5, x5, 1
addi x6, x0, 10
sub x5, x5, x6
slt x5, x5, x0
sll x5, x5, x5
slli x6, x6, 2
slli x6, x6, 0
sll x5, x5, x0
addi x5, x5, -10
slt x5, x5, x6
addi x5, x5, 10
addi x6, x6, -29
sll x6, x6, x5
#EXPECTED OUTPUT
#x5 1
#x6 20
