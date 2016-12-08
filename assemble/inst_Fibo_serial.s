xor 1 1 1
ori 2 0 1
lui 3 BFD0
addiu 3 3 3F8
ori 4 0 0
ori 5 0 14
addu 1 1 2
addu 2 1 2
sw 1 3 0
sw 2 3 0
addiu 4 4 2
subu 6 5 4
bgtz 6 FFF9
nop
beq 0 0 FFFF
nop
