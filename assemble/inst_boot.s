nop
nop
nop
nop
mtc0 13 0
mtc0 12 0
jal 9
nop
lb 13 0 EC40
lw 28 31 0
lui 29 8002
addiu 29 29 B424
lui 8 8002
addiu 8 8 9000
mtc0 15 8
mfc0 8 12
lui 9 FFBF
ori 9 9 FFFF
and 8 8 9
mtc0 12 8
lui 8 800D
addiu 8 8 6C50
lui 9 800E
addiu 9 9 A9D0
sw 0 8 0
addiu 8 8 4
slt 11 8 9
bgtz 11 FFFC
nop
addiu 29 29 FFF0
lui 25 8000
addiu 25 25 00BC
nop
beq 0 0 FFFF
nop
exit