library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.CPU32.all;


entity id is
  PORT(
    rst:in STD_LOGIC;
    pc_i:in STD_LOGIC_VECTOR(31 downto 0);  -- Program counter
    inst_i:in STD_LOGIC_VECTOR(31 downto 0);  -- Instruction
    reg1_data_i:in STD_LOGIC_VECTOR(31 downto 0); -- Result from register
    reg2_data_i:in STD_LOGIC_VECTOR(31 downto 0); -- Result from register
    reg1_read_o:buffer STD_LOGIC;  -- Control register reading
    reg2_read_o:buffer STD_LOGIC;  -- Control register reading
    reg1_addr_o:buffer STD_LOGIC_VECTOR(4 downto 0); --size = 5 Register address
    reg2_addr_o:buffer STD_LOGIC_VECTOR(4 downto 0); --size = 5 Register address
    ex_wreg_i:in STD_LOGIC; -- Data forwarding
    ex_wdata_i:in STD_LOGIC_VECTOR(31 downto 0); -- Data forwarding
    ex_wd_i:in STD_LOGIC_VECTOR(4 downto 0);  --size = 5 Data forwarding
    mem_wreg_i:in STD_LOGIC; -- Data forwarding
    mem_wdata_i:in STD_LOGIC_VECTOR(31 downto 0); -- Data forwarding
    mem_wd_i:in STD_LOGIC_VECTOR(4 downto 0); --size = 5 Data forwarding
    aluop_o:out STD_LOGIC_VECTOR(7 downto 0); --size = 8
    alusel_o:out STD_LOGIC_VECTOR(2 downto 0);  --size = 3
    reg1_o:buffer STD_LOGIC_VECTOR(31 downto 0); -- Operand 1
    reg2_o:buffer STD_LOGIC_VECTOR(31 downto 0); -- Operand 2
    wd_o:out STD_LOGIC_VECTOR(4 downto 0);  --size = 5 Write-Destination (register)
    wreg_o:out STD_LOGIC; -- =1 -> need to write reg
    is_in_delayslot_i:in STD_LOGIC;
    next_inst_in_delayslot_o:out STD_LOGIC;
    branch_flag_o:out STD_LOGIC;
    branch_target_address_o:out STD_LOGIC_VECTOR(31 downto 0);
    link_addr_o:out STD_LOGIC_VECTOR(31 downto 0);
    is_in_delayslot_o:out STD_LOGIC;
    inst_o:out STD_LOGIC_VECTOR(31 downto 0);
    stallreq:out STD_LOGIC; -- =1 -> stall pipeline
    ex_aluop_i:in STD_LOGIC_VECTOR(7 downto 0)
  );
end id;

architecture decode of id is
signal op:STD_LOGIC_VECTOR(5 downto 0);
signal op2:STD_LOGIC_VECTOR(4 downto 0);
signal op3:STD_LOGIC_VECTOR(5 downto 0);
signal op4:STD_LOGIC_VECTOR(4 downto 0);
signal imm:STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal instvalid:STD_LOGIC;
signal pc_plus_8: STD_LOGIC_VECTOR(31 downto 0);
signal pc_plus_4: STD_LOGIC_VECTOR(31 downto 0);
signal imm_sll2_signedext: STD_LOGIC_VECTOR(31 downto 0);

signal stallreq_for_reg1_loadrelate: STD_LOGIC;
signal stallreq_for_reg2_loadrelate: STD_LOGIC;
signal pre_inst_is_load: STD_LOGIC;

begin
  op<=inst_i(31 downto 26);
  op2<=inst_i(10 downto 6);
  op3<=inst_i(5 downto 0);
  op4<=inst_i(20 downto 16);
  stallreq <= '0';
  pc_plus_8 <= pc_i + x"00000010";
  pc_plus_4 <= pc_i + x"00000001";
  imm_sll2_signedext <= inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15 downto 0)&"00";
  inst_o <= inst_i;


  process(ex_aluop_i)
  begin
    if(ex_aluop_i = EXE_LB_OP or ex_aluop_i = EXE_LBU_OP or ex_aluop_i = EXE_LHU_OP or ex_aluop_i = EXE_LW_OP) then
      pre_inst_is_load <= '1';
    else
      pre_inst_is_load <= '0';
    end if;
  end process;

  process(rst, pc_i, inst_i, reg1_data_i, reg2_data_i, op, op2, op3, op4, pc_plus_4, pc_plus_8, imm_sll2_signedext, reg1_o, reg2_o)
  begin
    if rst = '1' then
      aluop_o <= "00000000";
      alusel_o <= "000";
      wd_o <= "00000";
      wreg_o <= '0';
      instvalid<='0';
      reg1_read_o <= '0';
      reg2_read_o <= '0';
      reg1_addr_o <= "00000";
      reg2_addr_o <= "00000";
      imm <= x"00000000";
      link_addr_o <= x"00000000";
      branch_target_address_o <= x"00000000";
      branch_flag_o <= '0';
      next_inst_in_delayslot_o <= '0';
    else
      case op is
        when EXE_ORI =>  --ORI
          wreg_o <= '1';
          aluop_o <= EXE_OR_OP;
          alusel_o <= "001";
          reg1_read_o <= '1';
          reg2_read_o <= '0';
          imm <= "0000000000000000"&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
			 reg1_addr_o <= inst_i(25 downto 21);
          instvalid <= '1';
        when EXE_ANDI =>
          wreg_o <= '1';
          aluop_o <= EXE_AND_OP;
          alusel_o <= EXE_RES_LOGIC;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
          imm <= "0000000000000000"&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
			 reg1_addr_o <= inst_i(25 downto 21);
          instvalid <= '1';
        when EXE_XORI =>
          wreg_o <= '1';
          aluop_o <= EXE_XOR_OP;
          alusel_o <= EXE_RES_LOGIC;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
          imm <= "0000000000000000"&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
			 reg1_addr_o <= inst_i(25 downto 21);
          instvalid <= '1';
        when EXE_LUI => -- op
          wreg_o <= '1';
          aluop_o <= EXE_OR_OP;
          alusel_o <= EXE_RES_LOGIC;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
			 imm <= inst_i(15 downto 0)&"0000000000000000";
          wd_o <= inst_i(20 downto 16);
			 reg1_addr_o <= "00000";
          instvalid <= '1';
        when EXE_SLTI =>  -- op
          wreg_o <= '1';
          aluop_o <= EXE_SLT_OP;
          alusel_o <= EXE_RES_ARITHMETIC;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
          imm <= inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
			 reg1_addr_o <= inst_i(25 downto 21);
          instvalid <= '1';
        when EXE_SLTIU =>  -- op
          wreg_o <= '1';
          aluop_o <= EXE_SLTU_OP;
          alusel_o <= EXE_RES_ARITHMETIC;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
          imm <= "0000000000000000"&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
			 reg1_addr_o <= inst_i(25 downto 21);
          instvalid <= '1';
        when EXE_ADDIU =>
          wreg_o <= '1';
          aluop_o <= EXE_ADDIU_OP;
          alusel_o <= EXE_RES_ARITHMETIC;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
          imm <= inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15)&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
			 reg1_addr_o <= inst_i(25 downto 21);
          instvalid <= '1';
        when EXE_J =>
          wreg_o <= '0';
          aluop_o <= EXE_J_OP;
          alusel_o <= EXE_RES_JUMP_BRANCH;
          reg1_read_o <= '0';
          reg2_read_o <= '0';
          link_addr_o <= x"00000000";
          branch_flag_o <= '1';
          next_inst_in_delayslot_o <= '1';
          instvalid <= '1';
          branch_target_address_o <= pc_plus_4(31 downto 28)&inst_i(25 downto 0)&"00";

        when EXE_JAL =>
          wreg_o <= '1';
          aluop_o <= EXE_JAL_OP;
          alusel_o <= EXE_RES_JUMP_BRANCH;
          reg1_read_o <= '0';
          reg2_read_o <= '0';
          wd_o <= "11111";
          link_addr_o <= pc_plus_8;
          branch_flag_o <= '1';
          next_inst_in_delayslot_o <= '1';
          instvalid <= '1';
          branch_target_address_o <= pc_plus_4(31 downto 28)&inst_i(25 downto 0)&"00";
        when EXE_BEQ =>
          wreg_o <= '0';
          aluop_o <= EXE_BEQ_OP;
          alusel_o <= EXE_RES_JUMP_BRANCH;
          reg1_read_o <= '1';
          reg2_read_o <= '1';
			 reg1_addr_o <= inst_i(25 downto 21);
			 reg2_addr_o <= inst_i(20 downto 16);
          instvalid <= '1';
          if reg1_o = reg2_o then
            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
            branch_flag_o <= '1';
            next_inst_in_delayslot_o <= '1';
          end if;
        when EXE_BGTZ =>
          wreg_o <= '0';
          aluop_o <= EXE_BGTZ_OP;
          alusel_o <= EXE_RES_JUMP_BRANCH;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
			 reg1_addr_o <= inst_i(25 downto 21);
          instvalid <= '1';
          if (reg1_o(31) = '0' and not (reg1_o = x"00000000")) then
            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
            branch_flag_o <= '1';
            next_inst_in_delayslot_o <= '1';
          end if;
        when EXE_BLEZ =>
          wreg_o <= '0';
          aluop_o <= EXE_BLEZ_OP;
          alusel_o <= EXE_RES_JUMP_BRANCH;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
			 reg1_addr_o <= inst_i(25 downto 21);
          instvalid <= '1';
          if (reg1_o(31) = '1' or reg1_o = x"00000000") then
            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
            branch_flag_o <= '1';
            next_inst_in_delayslot_o <= '1';
          end if;
        when EXE_BNE =>
          wreg_o <= '0';
          aluop_o <= EXE_BLEZ_OP;
          alusel_o <= EXE_RES_JUMP_BRANCH;
          reg1_read_o <= '1';
          reg2_read_o <= '1';
			 reg1_addr_o <= inst_i(25 downto 21);
			 reg2_addr_o <= inst_i(20 downto 16);
          instvalid <= '1';
          if not reg1_o = reg2_o then
            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
            branch_flag_o <= '1';
            next_inst_in_delayslot_o <= '1';
          end if;

        when EXE_LB =>
          wreg_o <= '1';
          aluop_o <= EXE_LB_OP;
          alusel_o <= EXE_RES_LOAD_STORE;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
          wd_o <= inst_i(20 downto 16);
			 reg1_addr_o <= inst_i(25 downto 21);
          instvalid <= '1';
        when EXE_LBU =>
          wreg_o <= '1';
          aluop_o <= EXE_LBU_OP;
          alusel_o <= EXE_RES_LOAD_STORE;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
          wd_o <= inst_i(20 downto 16);
			 reg1_addr_o <= inst_i(25 downto 21);
          instvalid <= '1';
        when EXE_LHU =>
          wreg_o <= '1';
          aluop_o <= EXE_LHU_OP;
          alusel_o <= EXE_RES_LOAD_STORE;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
          wd_o <= inst_i(20 downto 16);
			 reg1_addr_o <= inst_i(25 downto 21);
          instvalid <= '1';
        when EXE_LW =>
          wreg_o <= '1';
          aluop_o <= EXE_LW_OP;
          alusel_o <= EXE_RES_LOAD_STORE;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
			 reg1_addr_o <= inst_i(25 downto 21);
			 wd_o <= inst_i(20 downto 16);
			 instvalid <= '1';
        when EXE_SB =>
          wreg_o <= '0';
          aluop_o <= EXE_SB_OP;
          alusel_o <= EXE_RES_LOAD_STORE;
          reg1_read_o <= '1';
          reg2_read_o <= '1';
			 reg1_addr_o <= inst_i(25 downto 21);
			 reg2_addr_o <= inst_i(20 downto 16);
          instvalid <= '1';
        when EXE_SW =>
          wreg_o <= '0';
          aluop_o <= EXE_SW_OP;
          alusel_o <= EXE_RES_LOAD_STORE;
          reg1_read_o <= '1';
          reg2_read_o <= '1';
			 reg1_addr_o <= inst_i(25 downto 21);
			 reg2_addr_o <= inst_i(20 downto 16);
          instvalid <= '1';
        ----------------------APPEND OP HERE----------------------
        when EXE_REGIMM_INST =>
          case op4 is
            when EXE_BGEZ =>
              wreg_o <= '0';
              aluop_o <= EXE_BGEZ_OP;
              alusel_o <= EXE_RES_JUMP_BRANCH;
              reg1_read_o <= '1';
              reg2_read_o <= '0';
				  reg1_addr_o <= inst_i(25 downto 21);
              instvalid <= '1';
              if (reg1_o(31) = '0') then
                branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                branch_flag_o <= '1';
                next_inst_in_delayslot_o <= '1';
              end if;
            when EXE_BGEZAL =>
              wreg_o <= '1';
              aluop_o <= EXE_BGEZAL_OP;
              alusel_o <= EXE_RES_JUMP_BRANCH;
              reg1_read_o <= '1';
              reg2_read_o <= '0';
				  reg1_addr_o <= inst_i(25 downto 21);
              link_addr_o <= pc_plus_8;
              wd_o <= "11111";
              instvalid <= '1';
              if (reg1_o(31) = '0') then
                branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                branch_flag_o <= '1';
                next_inst_in_delayslot_o <= '1';
              end if;
            when EXE_BLTZ =>
              wreg_o <= '0';
              aluop_o <= EXE_BGEZAL_OP;
              alusel_o <= EXE_RES_JUMP_BRANCH;
              reg1_read_o <= '1';
              reg2_read_o <= '0';
				  reg1_addr_o <= inst_i(25 downto 21);
              instvalid <= '1';
              if (reg1_o(31) = '1') then
                branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                branch_flag_o <= '1';
                next_inst_in_delayslot_o <= '1';
              end if;
            when EXE_BLTZAL =>
              wreg_o <= '1';
              aluop_o <= EXE_BGEZAL_OP;
              alusel_o <= EXE_RES_JUMP_BRANCH;
              reg1_read_o <= '1';
              reg2_read_o <= '0';
				  reg1_addr_o <= inst_i(25 downto 21);
              link_addr_o <= pc_plus_8;
              wd_o <= "11111";
              instvalid <= '1';
              if (reg1_o(31) = '0') then
                branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                branch_flag_o <= '1';
                next_inst_in_delayslot_o <= '1';
              end if;
            when others =>
              NULL;
          end case;
        when EXE_SPECIAL =>
          case op2 is
            when "00000" =>
              case op3 is
                when EXE_OR =>  -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_OR_OP;
                  alusel_o <= EXE_RES_LOGIC;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
						reg1_addr_o <= inst_i(25 downto 21);
						reg2_addr_o <= inst_i(20 downto 16);
						wd_o <= inst_i(15 downto 11);
                  instvalid <= '1';
                when EXE_AND => -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_AND_OP;
                  alusel_o <= EXE_RES_LOGIC;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
						reg1_addr_o <= inst_i(25 downto 21);
						reg2_addr_o <= inst_i(20 downto 16);
						wd_o <= inst_i(15 downto 11);
                  instvalid <= '1';
                when EXE_XOR => -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_XOR_OP;
                  alusel_o <= EXE_RES_LOGIC;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
						reg1_addr_o <= inst_i(25 downto 21);
						reg2_addr_o <= inst_i(20 downto 16);
						wd_o <= inst_i(15 downto 11);
                  instvalid <= '1';
                when EXE_NOR => -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_NOR_OP;
                  alusel_o <= EXE_RES_LOGIC;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
						reg1_addr_o <= inst_i(25 downto 21);
						reg2_addr_o <= inst_i(20 downto 16);
						wd_o <= inst_i(15 downto 11);
                  instvalid <= '1';
                when EXE_SLLV =>  -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_SLL_OP;
                  alusel_o <= EXE_RES_SHIFT;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
						reg1_addr_o <= inst_i(25 downto 21);
						reg2_addr_o <= inst_i(20 downto 16);
						wd_o <= inst_i(15 downto 11);
                  instvalid <= '1';
                when EXE_SRLV =>  -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_SRL_OP;
                  alusel_o <= EXE_RES_SHIFT;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
						reg1_addr_o <= inst_i(25 downto 21);
						reg2_addr_o <= inst_i(20 downto 16);
						wd_o <= inst_i(15 downto 11);
                  instvalid <= '1';
                when EXE_SRAV =>  -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_SRA_OP;
                  alusel_o <= EXE_RES_SHIFT;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
						reg1_addr_o <= inst_i(25 downto 21);
						reg2_addr_o <= inst_i(20 downto 16);
						wd_o <= inst_i(15 downto 11);
                  instvalid <= '1';
                when EXE_MFHI =>  -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_MFHI_OP;
                  alusel_o <= EXE_RES_MOVE;
                  reg1_read_o <= '0';
                  reg2_read_o <= '0';
						wd_o <= inst_i(15 downto 11);
                  instvalid <= '1';
                when EXE_MTHI =>  -- op3
                  wreg_o <= '0';
                  aluop_o <= EXE_MTHI_OP;
                  reg1_read_o <= '1';
                  reg2_read_o <= '0';
						reg1_addr_o <= inst_i(25 downto 21);
                  instvalid <= '1';
                when EXE_MFLO =>  -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_MFLO_OP;
                  alusel_o <= EXE_RES_MOVE;
                  reg1_read_o <= '0';
                  reg2_read_o <= '0';
						wd_o <= inst_i(15 downto 11);
                  instvalid <= '1';
                when EXE_MTLO =>  -- op3
                  wreg_o <= '0';
                  aluop_o <= EXE_MTLO_OP;
                  reg1_read_o <= '1';
                  reg2_read_o <= '0';
						reg1_addr_o <= inst_i(25 downto 21);
                  instvalid <= '1';
                when EXE_SLT => -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_SLT_OP;
                  alusel_o <= EXE_RES_ARITHMETIC;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
						reg1_addr_o <= inst_i(25 downto 21);
						reg2_addr_o <= inst_i(20 downto 16);
						wd_o <= inst_i(15 downto 11);
                  instvalid <= '1';
                when EXE_SLTU => -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_SLTU_OP;
                  alusel_o <= EXE_RES_ARITHMETIC;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
						reg1_addr_o <= inst_i(25 downto 21);
						reg2_addr_o <= inst_i(20 downto 16);
						wd_o <= inst_i(15 downto 11);
                  instvalid <= '1';
                when EXE_ADDU => -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_ADDU_OP;
                  alusel_o <= EXE_RES_ARITHMETIC;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
						reg1_addr_o <= inst_i(25 downto 21);
						reg2_addr_o <= inst_i(20 downto 16);
						wd_o <= inst_i(15 downto 11);
                  instvalid <= '1';
                when EXE_SUBU => -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_SUBU_OP;
                  alusel_o <= EXE_RES_ARITHMETIC;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
						reg1_addr_o <= inst_i(25 downto 21);
						reg2_addr_o <= inst_i(20 downto 16);
                  wd_o <= inst_i(15 downto 11);
						instvalid <= '1';
                when EXE_MULT => -- op3
                  wreg_o <= '0';  -- Write Hi-Lo register instead
                  aluop_o <= EXE_MULT_OP;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
						reg1_addr_o <= inst_i(25 downto 21);
						reg2_addr_o <= inst_i(20 downto 16);
                  instvalid <= '1';
                when EXE_JR =>  -- op3
                  wreg_o <= '0';
                  aluop_o <= EXE_JR_OP;
                  alusel_o <= EXE_RES_JUMP_BRANCH;
                  reg1_read_o <= '1';
                  reg2_read_o <= '0';
						reg1_addr_o <= inst_i(25 downto 21);
                  link_addr_o <= x"00000000";
                  branch_target_address_o <= reg1_o;
                  branch_flag_o <= '1';
                  next_inst_in_delayslot_o <= '1';
                  instvalid <= '1';
                when EXE_JALR =>  -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_JALR_OP;
                  alusel_o <= EXE_RES_JUMP_BRANCH;
                  reg1_read_o <= '1';
                  reg2_read_o <= '0';
						reg1_addr_o <= inst_i(25 downto 21);
                  wd_o <= inst_i(15 downto 11);
                  link_addr_o <= pc_plus_8;
                  branch_target_address_o <= reg1_o;
                  branch_flag_o <= '1';
                  next_inst_in_delayslot_o <= '1';
                  instvalid <= '1';

                ----------------------APPEND OP3 HERE----------------------
                when others => NULL;
              end case; -- op3
            when others => NULL;
          end case; -- op2
          if inst_i(25 downto 21) = "00000" then -- inst_i(31 downto 21) = "00000000000"
            if op3 = EXE_SLL then
              wreg_o <= '1';
              aluop_o <= EXE_SLL_OP;
              alusel_o <= EXE_RES_SHIFT;
              reg1_read_o <= '0';
              reg2_read_o <= '1';
				  reg2_addr_o <= inst_i(20 downto 16);
              imm(4 downto 0) <= inst_i(10 downto 6);
              wd_o <= inst_i(15 downto 11);
              instvalid <= '1';
            elsif op3 = EXE_SRL then
              wreg_o <= '1';
              aluop_o <= EXE_SRL_OP;
              alusel_o <= EXE_RES_SHIFT;
              reg1_read_o <= '0';
              reg2_read_o <= '1';
				  reg2_addr_o <= inst_i(20 downto 16);
              imm(4 downto 0) <= inst_i(10 downto 6);
              wd_o <= inst_i(15 downto 11);
              instvalid <= '1';
            elsif op3 = EXE_SRA then
              wreg_o <= '1';
              aluop_o <= EXE_SRA_OP;
              alusel_o <= EXE_RES_SHIFT;
              reg1_read_o <= '0';
              reg2_read_o <= '1';
				  reg2_addr_o <= inst_i(20 downto 16);
              imm(4 downto 0) <= inst_i(10 downto 6);
              wd_o <= inst_i(15 downto 11);
              instvalid <= '1';
            end if;
          end if;

        when others =>  -- op
          aluop_o <= "00000000";
          alusel_o <= "000";
          wd_o <= inst_i(15 downto 11);
          wreg_o <= '0';
          instvalid<='0';
          reg1_read_o <= '0';
          reg2_read_o <= '0';
          reg1_addr_o <= inst_i(25 downto 21);
          reg2_addr_o <= inst_i(20 downto 16);
          imm <= x"00000000";
          link_addr_o <= x"00000000";
          branch_target_address_o <= x"00000000";
          branch_flag_o <= '0';
          next_inst_in_delayslot_o <= '0';
      end case; -- op

    end if;
  end process;

  process(rst, pc_i, inst_i, reg1_data_i, reg2_data_i, pre_inst_is_load, ex_wd_i, mem_wdata_i, ex_wdata_i, reg1_read_o, imm, reg1_addr_o, ex_wreg_i, mem_wreg_i, mem_wd_i)
  begin
    if rst = '1' then
      reg1_o <= x"00000000";
      stallreq_for_reg1_loadrelate <= '0';
    elsif (pre_inst_is_load = '1' and ex_wd_i = reg1_addr_o and reg1_read_o = '1') then
      reg1_o <= x"00000000";
      stallreq_for_reg1_loadrelate <= '1';
    elsif reg1_read_o = '1' and ex_wreg_i = '1' and ex_wd_i = reg1_addr_o then  -- ex-id conflict
      reg1_o <= ex_wdata_i;
      stallreq_for_reg1_loadrelate <= '0';
    elsif reg1_read_o = '1' and mem_wreg_i = '1' and mem_wd_i = reg1_addr_o then  -- mem-id conflict
      reg1_o <= mem_wdata_i;
      stallreq_for_reg1_loadrelate <= '0';
    elsif reg1_read_o = '1' then
      reg1_o <= reg1_data_i;
      stallreq_for_reg1_loadrelate <= '0';
    elsif reg1_read_o = '0' then
      reg1_o <= imm;
      stallreq_for_reg1_loadrelate <= '0';
    else
      reg1_o <= x"00000000";
      stallreq_for_reg1_loadrelate <= '0';
    end if;
  end process;

  process(rst, pc_i, inst_i, reg1_data_i, reg2_data_i, pre_inst_is_load, ex_wd_i, mem_wdata_i, ex_wdata_i, reg2_read_o, imm, reg2_addr_o, ex_wreg_i, mem_wreg_i, mem_wd_i)
  begin
    if rst = '1' then
      reg2_o <= x"00000000";
      stallreq_for_reg2_loadrelate <= '0';
    elsif (pre_inst_is_load = '1' and ex_wd_i = reg2_addr_o and reg2_read_o = '1') then
      reg2_o <= x"00000000";
      stallreq_for_reg2_loadrelate <= '1';
    elsif reg2_read_o = '1' and ex_wreg_i = '1' and ex_wd_i = reg2_addr_o then  -- ex-id conflict
      reg2_o <= ex_wdata_i;
      stallreq_for_reg2_loadrelate <= '0';
    elsif reg2_read_o = '1' and mem_wreg_i = '1' and mem_wd_i = reg2_addr_o then  -- mem-id conflict
      reg2_o <= mem_wdata_i;
      stallreq_for_reg2_loadrelate <= '0';
    elsif reg2_read_o = '1' then
      reg2_o <= reg2_data_i;
      stallreq_for_reg2_loadrelate <= '0';
    elsif reg2_read_o = '0' then
      reg2_o <= imm;
      stallreq_for_reg2_loadrelate <= '0';
    else
      reg2_o <= x"00000000";
      stallreq_for_reg2_loadrelate <= '0';
    end if;
  end process;

  process(rst, is_in_delayslot_i)

  begin
    if rst = '1' then
      is_in_delayslot_o <= '0';
    else
      is_in_delayslot_o <= is_in_delayslot_i;
    end if;
  end process;
end decode;
