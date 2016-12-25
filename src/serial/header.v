//basical definition
`define RstEnable     1'b0
`define RstDisable    1'b1
`define WriteEnable   1'b1
`define WriteDisable  1'b0
`define ReadEnable    1'b1
`define ReadDisable   1'b0
`define True          1'b1
`define False         1'b0
`define ChipEnable    1'b1
`define ChipDisable   1'b0
`define InstValid     1'b1
`define InstInvalid   1'b0
`define zeroWord      32'h00000000

//bus definition
`define ALU_OP_BUS      7:0
`define ALU_SEL_BUS     2:0
`define INST_ADDR_BUS   31:0
`define INST_BUS        31:0
`define REG_BUS         31:0
`define INST_BUS        31:0
`define REG_ADDR_BUS    4:0
`define REG_NUM         32
`define NOP_REG_ADDR    5'b00000

`define SEL_NOP         3'b000
`define OP_NOP          8'b00100100

//ALUsel_o
`define ARITH_SEL		3'b000
`define BRANCH_SEL	3'b001
`define MEM_SEL		3'b010
`define LOGIC_SEL 	3'b011
`define MOVE_SEL		3'b100
`define SHIFT_SEL		3'b101
`define TRAP_SEL		3'b110
`define PRIV_SEL		3'b111 //privilege

//ALUop_o
`define ADDIU_OP		8'b00000000
`define ADDU_OP		8'b00000001
`define MULT_OP		8'b00000010
`define SLT_OP			8'b00000011
`define SLTI_OP		8'b00000100
`define SLTIU_OP		8'b00000101
`define SLTU_OP		8'b00000110
`define SUBU_OP		8'b00000111
`define BEQ_OP			8'b00001000
`define BGEZ_OP		8'b00001001
`define BGTZ_OP		8'b00001010
`define BLEZ_OP		8'b00001011
`define BLTZ_OP		8'b00001100
`define BNE_OP			8'b00001101
`define J_OP			8'b00001110
`define JAL_OP			8'b00001111
`define JALR_OP		8'b00010000
`define JR_OP			8'b00010001
`define LB_OP			8'b00010010
`define LBU_OP			8'b00010011
`define LHU_OP			8'b00010100
`define LW_OP			8'b00010101
`define SB_OP			8'b00010110
`define SW_OP			8'b00010111
`define AND_OP			8'b00011000
`define ANDI_OP		8'b00011001
`define LUI_OP			8'b00011010
`define NOR_OP			8'b00011011
`define OR_OP			8'b00011100
`define ORI_OP			8'b00011101
`define XOR_OP			8'b00011110
`define XORI_OP		8'b00011111
`define MFHI_OP		8'b00100000
`define MFLO_OP		8'b00100001
`define MTHI_OP		8'b00100010
`define MTLO_OP		8'b00100011
`define SLL_OP			8'b00100100
`define SLLV_OP		8'b00100101
`define SRA_OP			8'b00100110
`define SRAV_OP		8'b00100111
`define SRL_OP			8'b00101000
`define SRLV_OP		8'b00101001
`define SYSCALL_OP	8'b00101010
`define ERET_OP		8'b00101011
`define MFC0_OP		8'b00101100
`define MTC0_OP		8'b00101101
`define TLBWI_OP		8'b00101110
`define DefineTimes	2'b00;


//Some other definition
`define STOP            1'b1
`define NOSTOP          1'b0
`define BRANCH          1'b1
`define NOTBRANCH       1'b0
`define INDELAYSLOT     1'b1
`define NOTINDELAYSLOT  1'b0


`define TLB_ENTRY_WIDTH	63
`define TLB_INDEX_WIDTH	4	// total 16 entries
`define TLB_NR_ENTRY	(1 << `TLB_INDEX_WIDTH)
`define TLB_WRITE_STRUCT_WIDTH	(`TLB_ENTRY_WIDTH + `TLB_INDEX_WIDTH + 1)
// enable, index, entry

// exc code definitions
`define EXC_CODE_WIDTH	5

`define EC_INT		5'h00	// interrupt
`define EC_TLB_MOD	5'h01	// modification exception
`define EC_TLBL		5'h02	// TLBL TLB invalid exception (load or instruction fetch)
`define EC_TLBS		5'h03	// TLBS TLB invalid exception (store)
`define EC_ADEL		5'h04	// AdEL Address error exception (load or instruction fetch)
`define EC_ADES		5'h05	// AdES Address error exception (store)
`define EC_SYS		5'h08	// Syscall exception
`define EC_RI		5'h0a	// reserved instruction
`define EC_CP_U		5'h0b	// Coprocessor Unusable exception

`define EC_NONE		5'h10	// dummy value for no exception
`define EC_ERET		5'h11	// dummy value to implement ERET