library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity id is
  PORT(
    rst:in STD_LOGIC;
    pc_i:in STD_LOGIC_VECTOR(31 downto 0);  -- Program counter
    inst_i:in STD_LOGIC_VECTOR(31 downto 0);  -- Instruction
    reg1_data_i:in STD_LOGIC_VECTOR(31 downto 0); -- Result from register
    reg2_data_i:in STD_LOGIC_VECTOR(31 downto 0); -- Result from register
    reg1_read_o:out STD_LOGIC;  -- Control register reading
    reg2_read_o:out STD_LOGIC;  -- Control register reading
    reg1_addr_o:out STD_LOGIC_VECTOR(4 downto 0); --size = 5 Register address
    reg2_addr_o:out STD_LOGIC_VECTOR(4 downto 0); --size = 5 Register address
    ex_wreg_i:in STD_LOGIC; -- Data forwarding
    ex_wdata_i:in STD_LOGIC_VECTOR(31 downto 0); -- Data forwarding
    ex_wd_i:in STD_LOGIC_VECTOR(4 downto 0);  --size = 5 Data forwarding
    mem_wreg_i:in STD_LOGIC; -- Data forwarding
    mem_wdata_i:in STD_LOGIC_VECTOR(31 downto 0); -- Data forwarding
    mem_wd_i:in STD_LOGIC_VECTOR(4 downto 0); --size = 5 Data forwarding
    aluop_o:out STD_LOGIC_VECTOR(7 downto 0); --size = 8
    alusel_o:out STD_LOGIC_VECTOR(2 downto 0);  --size = 3
    reg1_o:out STD_LOGIC_VECTOR(31 downto 0); -- Operand 1
    reg2_o:out STD_LOGIC_VECTOR(31 downto 0); -- Operand 2
    wd_o:out STD_LOGIC_VECTOR(4 downto 0);  --size = 5 Write-Destination (register)
    wreg_o:out STD_LOGIC -- =1 -> need to write reg
  );
end id;

architecture decode of id is
signal op:STD_LOGIC_VECTOR(5 downto 0);
signal op2:STD_LOGIC_VECTOR(4 downto 0);
signal op3:STD_LOGIC_VECTOR(5 downto 0);
signal op4:STD_LOGIC_VECTOR(4 downto 0);
signal imm:STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal reg1_read:STD_LOGIC;
signal reg2_read:STD_LOGIC;
signal reg1:STD_LOGIC_VECTOR(31 downto 0);
signal reg2:STD_LOGIC_VECTOR(31 downto 0);
signal instvalid:STD_LOGIC;

--instrs
constant EXE_ANDI:STD_LOGIC_VECTOR(5 downto 0) := "001100";
constant EXE_ORI:STD_LOGIC_VECTOR(5 downto 0) := "001101";
constant EXE_XORI:STD_LOGIC_VECTOR(5 downto 0) := "001110";
constant EXE_LUI:STD_LOGIC_VECTOR(5 downto 0) := "001111";
constant EXE_SPECIAL:STD_LOGIC_VECTOR(5 downto 0) := "000000";

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

constant EXE_MOVZ:STD_LOGIC_VECTOR(5 downto 0) := "001010";
constant EXE_MOVN:STD_LOGIC_VECTOR(5 downto 0) := "001011";
constant EXE_MFHI:STD_LOGIC_VECTOR(5 downto 0) := "010000";
constant EXE_MTHI:STD_LOGIC_VECTOR(5 downto 0) := "010001";
constant EXE_MFLO:STD_LOGIC_VECTOR(5 downto 0) := "010010";
constant EXE_MTLO:STD_LOGIC_VECTOR(5 downto 0) := "010011";

--ALU OPs
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

--ALU SELECTORs
CONSTANT EXE_RES_NOP: STD_LOGIC_VECTOR(2 downto 0) := "000";
CONSTANT EXE_RES_LOGIC: STD_LOGIC_VECTOR(2 downto 0) := "001";
CONSTANT EXE_RES_SHIFT: STD_LOGIC_VECTOR(2 downto 0) := "010";
CONSTANT EXE_RES_MOVE: STD_LOGIC_VECTOR(2 downto 0) := "011";

begin
  op<=inst_i(31 downto 26);
  op2<=inst_i(10 downto 6);
  op3<=inst_i(5 downto 0);
  op4<=inst_i(20 downto 16);
  reg1_read_o <= reg1_read;
  reg2_read_o <= reg2_read;
  reg1_o <= reg1;
  reg2_o <= reg2;
  process(rst, pc_i, inst_i, reg1_data_i, reg2_data_i)
  begin
    if rst = '0' then
      aluop_o <= "00000000";
      alusel_o <= "000";
      wd_o <= "00000";
      wreg_o <= '0';
      instvalid<='0';
      reg1_read <= '0';
      reg2_read <= '0';
      reg1_addr_o <= "00000";
      reg2_addr_o <= "00000";
      imm <= x"00000000";
    else
      case op is
        when EXE_ORI =>  --ORI
          wreg_o <= '1';
          aluop_o <= EXE_OR_OP;
          alusel_o <= "001";
          reg1_read <= '1';
          reg2_read <= '0';
          imm <= "0000000000000000"&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
          instvalid <= '1';
        when EXE_ANDI =>
          wreg_o <= '1';
          aluop_o <= EXE_AND_OP;
          alusel_o <= EXE_RES_LOGIC;
          reg1_read <= '1';
          reg2_read <= '0';
          imm <= "0000000000000000"&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
          instvalid <= '1';
        when EXE_XORI =>
          wreg_o <= '1';
          aluop_o <= EXE_XOR_OP;
          alusel_o <= EXE_RES_LOGIC;
          reg1_read <= '1';
          reg2_read <= '0';
          imm <= "0000000000000000"&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
          instvalid <= '1';
        when EXE_LUI =>
          wreg_o <= '1';
          aluop_o <= EXE_OR_OP;
          alusel_o <= EXE_RES_LOGIC;
          reg1_read <= '1';
          reg2_read <= '0';
          imm <= "0000000000000000"&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
          instvalid <= '1';

        when EXE_SPECIAL =>
          case op2 is
            when "00000" =>
              case op3 is
                when EXE_OR =>
                  wreg_o <= '1';
                  aluop_o <= EXE_OR_OP;
                  alusel_o <= EXE_RES_LOGIC;
                  reg1_read <= '1';
                  reg2_read <= '1';
                  instvalid <= '1';
                when EXE_AND =>
                  wreg_o <= '1';
                  aluop_o <= EXE_AND_OP;
                  alusel_o <= EXE_RES_LOGIC;
                  reg1_read <= '1';
                  reg2_read <= '1';
                  instvalid <= '1';
                when EXE_XOR =>
                  wreg_o <= '1';
                  aluop_o <= EXE_XOR_OP;
                  alusel_o <= EXE_RES_LOGIC;
                  reg1_read <= '1';
                  reg2_read <= '1';
                  instvalid <= '1';
                when EXE_NOR =>
                  wreg_o <= '1';
                  aluop_o <= EXE_NOR_OP;
                  alusel_o <= EXE_RES_LOGIC;
                  reg1_read <= '1';
                  reg2_read <= '1';
                  instvalid <= '1';
                when EXE_SLLV =>
                  wreg_o <= '1';
                  aluop_o <= EXE_SLL_OP;
                  alusel_o <= EXE_RES_SHIFT;
                  reg1_read <= '1';
                  reg2_read <= '1';
                  instvalid <= '1';
                when EXE_SRLV =>
                  wreg_o <= '1';
                  aluop_o <= EXE_SRL_OP;
                  alusel_o <= EXE_RES_SHIFT;
                  reg1_read <= '1';
                  reg2_read <= '1';
                  instvalid <= '1';
                when EXE_SRAV =>
                  wreg_o <= '1';
                  aluop_o <= EXE_SRA_OP;
                  alusel_o <= EXE_RES_SHIFT;
                  reg1_read <= '1';
                  reg2_read <= '1';
                  instvalid <= '1';
                when EXE_MFHI =>
                  wreg_o <= '1';
                  aluop_o <= EXE_MFHI_OP;
                  alusel_o <= EXE_RES_MOVE;
                  reg1_read <= '0';
                  reg2_read <= '0';
                  instvalid <= '1';
                when EXE_MTHI =>
                  wreg_o <= '1';
                  aluop_o <= EXE_MTHI_OP;
                  reg1_read <= '1';
                  reg2_read <= '0';
                  instvalid <= '1';
                when EXE_MFLO =>
                  wreg_o <= '1';
                  aluop_o <= EXE_MFLO_OP;
                  alusel_o <= EXE_RES_MOVE;
                  reg1_read <= '0';
                  reg2_read <= '0';
                  instvalid <= '1';
                when EXE_MTLO =>
                  wreg_o <= '1';
                  aluop_o <= EXE_MTLO_OP;
                  reg1_read <= '1';
                  reg2_read <= '0';
                  instvalid <= '1';
                when others => NULL;
              end case; -- op3
            when others => NULL;
          end case; -- op2
          if inst_i(25 downto 21 = "00000") then -- inst_i(31 downto 21) = "00000000000"
            if op3 = EXE_SLL then
              wreg_o <= '1';
              aluop_o <= EXE_SLL_OP;
              alusel_o <= EXE_RES_SHIFT;
              reg1_read_o <= '0';
              reg2_read_o <= '1';
              imm(4 downto 0) <= inst_i(10 downto 6);
              wd_o <= inst_i(15 downto 11);
              instvalid <= '1';
            elsif op3 = EXE_SRL then
              wreg_o <= '1';
              aluop_o <= EXE_SRL_OP;
              alusel_o <= EXE_RES_SHIFT;
              reg1_read <= '0';
              reg2_read <= '1';
              imm(4 downto 0) <= inst_i(10 downto 6);
              wd_o <= inst_i(15 downto 11);
              instvalid <= '1';
            elsif op3 = EXE_SRA then
              wreg_o <= '1';
              alu_op_o <= EXE_SRA_OP;
              alu_sel_o <= EXE_RES_SHIFT;
              reg1_read <= '0';
              reg2_read <= '1';
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
          reg1_read <= '0';
          reg2_read <= '0';
          reg1_addr_o <= inst_i(25 downto 21);
          reg2_addr_o <= inst_i(20 downto 16);
          imm <= x"00000000";
      end case; -- op

    end if;
  end process;

  process(rst, pc_i, inst_i, reg1_data_i, reg2_data_i)

  begin
    if rst = '1' then
      reg1 <= x"00000000";
    elsif reg1_read = '1' and ex_wreg_i = '1' and ex_wd_i = reg1_addr_o then  -- ex-id conflict
      reg1 <= ex_wdata_i;
    elsif reg1_read = '1' and mem_wreg_i = '1' and mem_wd_i = reg1_addr_o then  -- mem-id conflict
      reg1 <= mem_wdata_i;
    elsif reg1_read = '1' then
      reg1 <= reg1_data_i;
    elsif reg1_read = '0' then
      reg1 <= imm;
    else
      reg1 <= x"00000000";
    end if;
  end process;

  process(rst, pc_i, inst_i, reg1_data_i, reg2_data_i)

  begin
    if rst = '1' then
      reg2 <= x"00000000";
    elsif reg2_read = '1' and ex_wreg_i = '1' and ex_wd_i = reg2_addr_o then  -- ex-id conflict
      reg2 <= ex_wdata_i;
    elsif reg2_read = '1' and mem_wreg_i = '1' and mem_wd_i = reg2_addr_o then  -- mem-id conflict
      reg2 <= mem_wdata_i;
    elsif reg2_read = '1' then
      reg2 <= reg2_data_i;
    elsif reg2_read = '0' then
      reg2 <= imm;
    else
      reg2 <= x"00000000";
    end if;
  end process;
end decode;
