LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;
package CPU32 is

    --instrs
    constant EXE_ANDI:STD_LOGIC_VECTOR(5 downto 0) := "001100";
    constant EXE_ORI:STD_LOGIC_VECTOR(5 downto 0) := "001101";
    constant EXE_XORI:STD_LOGIC_VECTOR(5 downto 0) := "001110";
    constant EXE_LUI:STD_LOGIC_VECTOR(5 downto 0) := "001111";
    constant EXE_SPECIAL:STD_LOGIC_VECTOR(5 downto 0) := "000000";
    constant EXE_REGIMM_INST:STD_LOGIC_VECTOR(5 downto 0) := "000001";
    constant EXE_J:STD_LOGIC_VECTOR(5 downto 0) := "000010";
    constant EXE_JAL:STD_LOGIC_VECTOR(5 downto 0) := "000011";
    constant EXE_BEQ:STD_LOGIC_VECTOR(5 downto 0) := "000100";
    constant EXE_BGTZ:STD_LOGIC_VECTOR(5 downto 0) := "000111";
    constant EXE_BLEZ:STD_LOGIC_VECTOR(5 downto 0) := "000110";
    constant EXE_BNE:STD_LOGIC_VECTOR(5 downto 0) := "000101";

    constant EXE_SLTI:STD_LOGIC_VECTOR(5 downto 0) := "001010";
    constant EXE_SLTIU:STD_LOGIC_VECTOR(5 downto 0) := "001011";
    constant EXE_ADDIU:STD_LOGIC_VECTOR(5 downto 0) := "001001";

    constant EXE_LB:STD_LOGIC_VECTOR(5 downto 0) := "100000";
    constant EXE_LBU:STD_LOGIC_VECTOR(5 downto 0) := "100100";
    constant EXE_LHU:STD_LOGIC_VECTOR(5 downto 0) := "100101";
    constant EXE_LW:STD_LOGIC_VECTOR(5 downto 0) := "100011";
    constant EXE_SB:STD_LOGIC_VECTOR(5 downto 0) := "101000";
    constant EXE_SW:STD_LOGIC_VECTOR(5 downto 0) := "101011";

    constant EXE_CP0:STD_LOGIC_VECTOR(5 downto 0) := "010000";


    --funcs
    constant EXE_AND:STD_LOGIC_VECTOR(5 downto 0) := "100100";
    constant EXE_OR:STD_LOGIC_VECTOR(5 downto 0) := "100101";
    constant EXE_XOR:STD_LOGIC_VECTOR(5 downto 0) := "100110";
    constant EXE_NOR:STD_LOGIC_VECTOR(5 downto 0) := "100111";

    constant EXE_SLL:STD_LOGIC_VECTOR(5 downto 0) := "000000";
    constant EXE_SLLV:STD_LOGIC_VECTOR(5 downto 0) := "000100";
    constant EXE_SRL:STD_LOGIC_VECTOR(5 downto 0) := "000010";
    constant EXE_SRLV:STD_LOGIC_VECTOR(5 downto 0) := "000110";
    constant EXE_SRA:STD_LOGIC_VECTOR(5 downto 0) := "000011";
    constant EXE_SRAV:STD_LOGIC_VECTOR(5 downto 0) := "000111";

    constant EXE_SLT:STD_LOGIC_VECTOR(5 downto 0) := "101010";
    constant EXE_SLTU:STD_LOGIC_VECTOR(5 downto 0) := "101011";

    constant EXE_ADDU:STD_LOGIC_VECTOR(5 downto 0) := "100001";
    constant EXE_SUBU:STD_LOGIC_VECTOR(5 downto 0) := "100011";
    constant EXE_MULT:STD_LOGIC_VECTOR(5 downto 0) := "011000";

    constant EXE_MOVZ:STD_LOGIC_VECTOR(5 downto 0) := "001010";
    constant EXE_MOVN:STD_LOGIC_VECTOR(5 downto 0) := "001011";
    constant EXE_MFHI:STD_LOGIC_VECTOR(5 downto 0) := "010000";
    constant EXE_MTHI:STD_LOGIC_VECTOR(5 downto 0) := "010001";
    constant EXE_MFLO:STD_LOGIC_VECTOR(5 downto 0) := "010010";
    constant EXE_MTLO:STD_LOGIC_VECTOR(5 downto 0) := "010011";

    constant EXE_JR:STD_LOGIC_VECTOR(5 downto 0) := "001000";
    constant EXE_JALR:STD_LOGIC_VECTOR(5 downto 0) := "001001";

  -- op4
    constant EXE_BGEZ:STD_LOGIC_VECTOR(4 downto 0) := "00001";
    constant EXE_BGEZAL:STD_LOGIC_VECTOR(4 downto 0) := "10001";
    constant EXE_BLTZ:STD_LOGIC_VECTOR(4 downto 0) := "00000";
    constant EXE_BLTZAL:STD_LOGIC_VECTOR(4 downto 0) := "10000";




  -- ALU ops
    CONSTANT EXE_OR_OP: STD_LOGIC_VECTOR(7 downto 0) := "00100101";
    CONSTANT EXE_NOP_OP: STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    CONSTANT EXE_AND_OP: STD_LOGIC_VECTOR(7 downto 0) := "00100100";
    CONSTANT EXE_NOR_OP: STD_LOGIC_VECTOR(7 downto 0) := "00100111";
    CONSTANT EXE_XOR_OP: STD_LOGIC_VECTOR(7 downto 0) := "00100110";

    CONSTANT EXE_SLL_OP: STD_LOGIC_VECTOR(7 downto 0) := "00000100";
    CONSTANT EXE_SRL_OP: STD_LOGIC_VECTOR(7 downto 0) := "00000110";
    CONSTANT EXE_SRA_OP: STD_LOGIC_VECTOR(7 downto 0) := "00000111";

    CONSTANT EXE_MFHI_OP: STD_LOGIC_VECTOR(7 downto 0) := "00010000";
    CONSTANT EXE_MTHI_OP: STD_LOGIC_VECTOR(7 downto 0) := "00010001";
    CONSTANT EXE_MFLO_OP: STD_LOGIC_VECTOR(7 downto 0) := "00010010";
    CONSTANT EXE_MTLO_OP: STD_LOGIC_VECTOR(7 downto 0) := "00010011";

    CONSTANT EXE_SLT_OP: STD_LOGIC_VECTOR(7 downto 0) := "00101010";
    CONSTANT EXE_SLTU_OP: STD_LOGIC_VECTOR(7 downto 0) := "00101011";
    CONSTANT EXE_ADDU_OP: STD_LOGIC_VECTOR(7 downto 0) := "00100001";
    CONSTANT EXE_SUBU_OP: STD_LOGIC_VECTOR(7 downto 0) := "00100011";
    CONSTANT EXE_ADDIU_OP: STD_LOGIC_VECTOR(7 downto 0) := "00001001";
    CONSTANT EXE_MULT_OP: STD_LOGIC_VECTOR(7 downto 0) := "00011000";

    constant EXE_BGEZ_OP:STD_LOGIC_VECTOR(7 downto 0) := "01000001";
    constant EXE_J_OP:STD_LOGIC_VECTOR(7 downto 0) := "01000010";
    constant EXE_JAL_OP:STD_LOGIC_VECTOR(7 downto 0) := "01000011";
    constant EXE_BEQ_OP:STD_LOGIC_VECTOR(7 downto 0) := "01000100";
    constant EXE_BLEZ_OP:STD_LOGIC_VECTOR(7 downto 0) := "01000110";
    constant EXE_BGTZ_OP:STD_LOGIC_VECTOR(7 downto 0) := "01000111";
    constant EXE_JR_OP:STD_LOGIC_VECTOR(7 downto 0) := "01001000";
    constant EXE_JALR_OP:STD_LOGIC_VECTOR(7 downto 0) := "01001001";
    constant EXE_BGEZAL_OP:STD_LOGIC_VECTOR(7 downto 0) := "01010001";

    constant EXE_LB_OP:STD_LOGIC_VECTOR(7 downto 0) := "01100000";
    constant EXE_LBU_OP:STD_LOGIC_VECTOR(7 downto 0) := "01100100";
    constant EXE_LHU_OP:STD_LOGIC_VECTOR(7 downto 0) := "01100101";
    constant EXE_LW_OP:STD_LOGIC_VECTOR(7 downto 0) := "01100011";
    constant EXE_SB_OP:STD_LOGIC_VECTOR(7 downto 0) := "01101000";
    constant EXE_SW_OP:STD_LOGIC_VECTOR(7 downto 0) := "01101011";

    constant EXE_MFC0_OP:STD_LOGIC_VECTOR(7 downto 0) := "01101100";
    constant EXE_MTC0_OP:STD_LOGIC_VECTOR(7 downto 0) := "01101101";

    constant EXE_SYSCALL_OP: STD_LOGIC_VECTOR(7 downto 0) := "10000000";
    constant EXE_ERET_OP: STD_LOGIC_VECTOR(7 downto 0) := "10000001";

  -- selectors
    CONSTANT EXE_RES_NOP: STD_LOGIC_VECTOR(2 downto 0) := "000";
    CONSTANT EXE_RES_LOGIC: STD_LOGIC_VECTOR(2 downto 0) := "001";
    CONSTANT EXE_RES_SHIFT: STD_LOGIC_VECTOR(2 downto 0) := "010";
    CONSTANT EXE_RES_MOVE: STD_LOGIC_VECTOR(2 downto 0) := "011";
    CONSTANT EXE_RES_ARITHMETIC: STD_LOGIC_VECTOR(2 downto 0) := "100";
    CONSTANT EXE_RES_MUL: STD_LOGIC_VECTOR(2 downto 0) := "101";
    CONSTANT EXE_RES_JUMP_BRANCH: STD_LOGIC_VECTOR(2 downto 0) := "110";
    CONSTANT EXE_RES_LOAD_STORE: STD_LOGIC_VECTOR(2 downto 0) := "111";

  -- mmu
    constant TLB_ENTRY_WIDTH :  integer := 63;
    constant TLB_NUM_ENTRY : integer := 128;
    constant TLB_INDEX_WIDTH : integer := 7;
    constant TLB_WRITE_STRUCT_WIDTH : integer := TLB_ENTRY_WIDTH + TLB_INDEX_WIDTH;

    constant VIRTUAL_SERIAL_DATA : std_logic_vector(31 downto 0) := x"bFD003F8";
    constant VIRTUAL_SERIAL_STATUS : std_logic_vector(31 downto 0) := x"bFD003FC";
    constant PHYSICAL_SERIAL_DATA : std_logic_vector(31 downto 0) := x"1FD003F8";
    constant PHYSICAL_SERIAL_STATUS : std_logic_vector(31 downto 0) := x"1FD003FC";


    constant NO_MEM_EXC : std_logic_vector(2 downto 0) := "000";
    constant TLB_MODIFIED : std_logic_vector(2 downto 0) := "001";
    constant TLB_L : std_logic_vector(2 downto 0) := "010";
    constant TLB_S : std_logic_vector(2 downto 0) := "011";
    constant ADE_L : std_logic_vector(2 downto 0) := "100";
    constant ADE_S : std_logic_vector(2 downto 0) := "101";

    constant ALIGN_TYPE_WORD : std_logic_vector(1 downto 0) := "00";
    constant ALIGN_TYPE_HALF_WORD : std_logic_vector(1 downto 0) := "01";
    constant ALIGN_TYPE_BYTE : std_logic_vector(1 downto 0) := "10";

    constant INVALID_CONTENT : std_logic_vector(31 downto 0) := x"FFFFFFFF";


end CPU32;
