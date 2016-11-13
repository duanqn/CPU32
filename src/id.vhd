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
    reg1_o:out STD_LOGIC_VECTOR(31 downto 0); -- Operand 1
    reg2_o:out STD_LOGIC_VECTOR(31 downto 0); -- Operand 2
    wd_o:out STD_LOGIC_VECTOR(4 downto 0);  --size = 5 Write-Destination (register)
    wreg_o:out STD_LOGIC; -- =1 -> need to write reg
    stallreq:out STD_LOGIC -- =1 -> stall pipeline
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

begin
  op<=inst_i(31 downto 26);
  op2<=inst_i(10 downto 6);
  op3<=inst_i(5 downto 0);
  op4<=inst_i(20 downto 16);
  reg1_o <= reg1;
  reg2_o <= reg2;
  stallreq <= '0';
  process(rst, pc_i, inst_i, reg1_data_i, reg2_data_i)
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
          instvalid <= '1';
        when EXE_ANDI =>
          wreg_o <= '1';
          aluop_o <= EXE_AND_OP;
          alusel_o <= EXE_RES_LOGIC;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
          imm <= "0000000000000000"&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
          instvalid <= '1';
        when EXE_XORI =>
          wreg_o <= '1';
          aluop_o <= EXE_XOR_OP;
          alusel_o <= EXE_RES_LOGIC;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
          imm <= "0000000000000000"&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
          instvalid <= '1';
        when EXE_LUI => -- op
          wreg_o <= '1';
          aluop_o <= EXE_OR_OP;
          alusel_o <= EXE_RES_LOGIC;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
          imm <= "0000000000000000"&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
          instvalid <= '1';
        when EXE_SLTI =>  -- op
          wreg_o <= '1';
          aluop_o <= EXE_SLT_OP;
          alusel_o <= EXE_RES_ARITHMETIC;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
          imm <= "0000000000000000"&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
          instvalid <= '1';
        when EXE_SLTIU =>  -- op
          wreg_o <= '1';
          aluop_o <= EXE_SLTU_OP;
          alusel_o <= EXE_RES_ARITHMETIC;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
          imm <= "0000000000000000"&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
          instvalid <= '1';
        when EXE_ADDIU =>
          wreg_o <= '1';
          aluop_o <= EXE_ADDIU_OP;
          alusel_o <= EXE_RES_ARITHMETIC;
          reg1_read_o <= '1';
          reg2_read_o <= '0';
          imm <= "0000000000000000"&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
          instvalid <= '1';
        ----------------------APPEND HERE----------------------
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
                  instvalid <= '1';
                when EXE_AND => -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_AND_OP;
                  alusel_o <= EXE_RES_LOGIC;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
                  instvalid <= '1';
                when EXE_XOR => -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_XOR_OP;
                  alusel_o <= EXE_RES_LOGIC;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
                  instvalid <= '1';
                when EXE_NOR => -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_NOR_OP;
                  alusel_o <= EXE_RES_LOGIC;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
                  instvalid <= '1';
                when EXE_SLLV =>  -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_SLL_OP;
                  alusel_o <= EXE_RES_SHIFT;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
                  instvalid <= '1';
                when EXE_SRLV =>  -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_SRL_OP;
                  alusel_o <= EXE_RES_SHIFT;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
                  instvalid <= '1';
                when EXE_SRAV =>  -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_SRA_OP;
                  alusel_o <= EXE_RES_SHIFT;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
                  instvalid <= '1';
                when EXE_MFHI =>  -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_MFHI_OP;
                  alusel_o <= EXE_RES_MOVE;
                  reg1_read_o <= '0';
                  reg2_read_o <= '0';
                  instvalid <= '1';
                when EXE_MTHI =>  -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_MTHI_OP;
                  reg1_read_o <= '1';
                  reg2_read_o <= '0';
                  instvalid <= '1';
                when EXE_MFLO =>  -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_MFLO_OP;
                  alusel_o <= EXE_RES_MOVE;
                  reg1_read_o <= '0';
                  reg2_read_o <= '0';
                  instvalid <= '1';
                when EXE_MTLO =>  -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_MTLO_OP;
                  reg1_read_o <= '1';
                  reg2_read_o <= '0';
                  instvalid <= '1';
                when EXE_SLT => -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_SLT_OP;
                  alusel_o <= EXE_RES_ARITHMATIC;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
                  instvalid <= '1';
                when EXE_SLTU => -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_SLT_OP;
                  alusel_o <= EXE_RES_ARITHMATIC;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
                  instvalid <= '1';
                when EXE_ADDU => -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_ADDU_OP;
                  alusel_o <= EXE_RES_ARITHMATIC;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
                  instvalid <= '1';
                when EXE_SUBU => -- op3
                  wreg_o <= '1';
                  aluop_o <= EXE_SUBU_OP;
                  alusel_o <= EXE_RES_ARITHMATIC;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
                  instvalid <= '1';
                when EXE_MULT => -- op3
                  wreg_o <= '0';  -- Write Hi-Lo register instead
                  aluop_o <= EXE_MULT_OP;
                  reg1_read_o <= '1';
                  reg2_read_o <= '1';
                  instvalid <= '1';
                ----------------------APPEND HERE----------------------
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
              imm(4 downto 0) <= inst_i(10 downto 6);
              wd_o <= inst_i(15 downto 11);
              instvalid <= '1';
            elsif op3 = EXE_SRL then
              wreg_o <= '1';
              aluop_o <= EXE_SRL_OP;
              alusel_o <= EXE_RES_SHIFT;
              reg1_read_o <= '0';
              reg2_read_o <= '1';
              imm(4 downto 0) <= inst_i(10 downto 6);
              wd_o <= inst_i(15 downto 11);
              instvalid <= '1';
            elsif op3 = EXE_SRA then
              wreg_o <= '1';
              aluop_o <= EXE_SRA_OP;
              alusel_o <= EXE_RES_SHIFT;
              reg1_read_o <= '0';
              reg2_read_o <= '1';
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
      end case; -- op

    end if;
  end process;

  process(rst, pc_i, inst_i, reg1_data_i, reg2_data_i)

  begin
    if rst = '1' then
      reg1 <= x"00000000";
    elsif reg1_read_o = '1' and ex_wreg_i = '1' and ex_wd_i = reg1_addr_o then  -- ex-id conflict
      reg1 <= ex_wdata_i;
    elsif reg1_read_o = '1' and mem_wreg_i = '1' and mem_wd_i = reg1_addr_o then  -- mem-id conflict
      reg1 <= mem_wdata_i;
    elsif reg1_read_o = '1' then
      reg1 <= reg1_data_i;
    elsif reg1_read_o = '0' then
      reg1 <= imm;
    else
      reg1 <= x"00000000";
    end if;
  end process;

  process(rst, pc_i, inst_i, reg1_data_i, reg2_data_i)

  begin
    if rst = '1' then
      reg2 <= x"00000000";
    elsif reg2_read_o = '1' and ex_wreg_i = '1' and ex_wd_i = reg2_addr_o then  -- ex-id conflict
      reg2 <= ex_wdata_i;
    elsif reg2_read_o = '1' and mem_wreg_i = '1' and mem_wd_i = reg2_addr_o then  -- mem-id conflict
      reg2 <= mem_wdata_i;
    elsif reg2_read_o = '1' then
      reg2 <= reg2_data_i;
    elsif reg2_read_o = '0' then
      reg2 <= imm;
    else
      reg2 <= x"00000000";
    end if;
  end process;
end decode;
