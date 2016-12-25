lui 4 9E00
ori 2 2 40
lui 5 8000
xor 3 3 3
addu 8 4 3
lhu 1 8 0
lhu 7 8 2
sll 7 7 16
or 1 1 7
addu 8 5 3
sw 1 8 0
lui 6 BFD0
addiu 6 6 3F8
sw 1 6 0
addiu 3 3 4
subu 6 2 3
bgtz 6 FFF3
nop
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
exit
