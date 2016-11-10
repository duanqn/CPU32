library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity id is
  PORT(
    rst:in STD_LOGIC;
    pc_i:in STD_LOGIC_VECTOR(31 downto 0);
    inst_i:in STD_LOGIC_VECTOR(31 downto 0);
    reg1_data_i:in STD_LOGIC_VECTOR(31 downto 0);
    reg2_data_i:in STD_LOGIC_VECTOR(31 downto 0);
    reg1_read_o:out STD_LOGIC;
    reg2_read_o:out STD_LOGIC;
    reg1_addr_o:out STD_LOGIC_VECTOR(4 downto 0); --size = 5
    reg2_addr_o:out STD_LOGIC_VECTOR(4 downto 0); --size = 5
    aluop_o:out STD_LOGIC_VECTOR(7 downto 0); --size = 8
    alusel_o:out STD_LOGIC_VECTOR(2 downto 0);  --size = 3
    reg1_o:out STD_LOGIC_VECTOR(31 downto 0);
    reg2_o:out STD_LOGIC_VECTOR(31 downto 0);
    wd_o:out STD_LOGIC_VECTOR(4 downto 0);  --size = 5
    wreg_o:out STD_LOGIC
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
signal instvalid:STD_LOGIC;
begin
  op<=inst_i(31 downto 26);
  op2<=inst_i(10 downto 6);
  op3<=inst_i(5 downto 0);
  op4<=inst_i(20 downto 16);
  reg1_read_o <= reg1_read;
  reg2_read_o <= reg2_read;
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
      
      case op is
        when "001101" =>  --ORI
          wreg_o <= '1';
          aluop_o <= "00100101";  -- ALU: OR
          alusel_o <= "001";
          reg1_read <= '1';
          reg2_read <= '0';
          imm <= "0000000000000000"&inst_i(15 downto 0);
          wd_o <= inst_i(20 downto 16);
          instvalid<='1';
        when others =>
          NULL;
      end case;
    end if;
  end process;
  
  process(rst, pc_i, inst_i, reg1_data_i, reg2_data_i)
  
  begin
    if rst = '1' then
      reg1_o <= x"00000000";
    elsif reg1_read = '1' then
      reg1_o <= reg1_data_i; 
    elsif reg1_read = '0' then
      reg1_o <= imm;
    else
      reg1_o <= x"00000000";
    end if;
  end process;
  
  process(rst, pc_i, inst_i, reg1_data_i, reg2_data_i)
  
  begin
    if rst = '1' then
      reg2_o <= x"00000000";
    elsif reg2_read = '1' then
      reg2_o <= reg2_data_i;
    elsif reg2_read = '0' then
      reg2_o <= imm;
    else
      reg2_o <= x"00000000";
    end if;
  end process;
end decode;