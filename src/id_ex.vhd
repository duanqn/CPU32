LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;

ENTITY id_ex IS
  PORT(
    clk: IN STD_LOGIC;
    rst: IN STD_LOGIC;
    id_aluop: IN STD_LOGIC_VECTOR (7 downto 0);
    id_alusel: IN STD_LOGIC_VECTOR (2 downto 0);
    id_reg1: IN STD_LOGIC_VECTOR (31 downto 0);
    id_reg2: IN STD_LOGIC_VECTOR (31 downto 0);
    id_wd: IN STD_LOGIC_VECTOR (4 downto 0);
    id_wreg: IN STD_LOGIC;

    ex_aluop: OUT STD_LOGIC_VECTOR (7 downto 0);
    ex_alusel: OUT STD_LOGIC_VECTOR (2 downto 0);
    ex_reg1: OUT STD_LOGIC_VECTOR (31 downto 0);
    ex_reg2: OUT STD_LOGIC_VECTOR (31 downto 0);
    ex_wd: OUT STD_LOGIC_VECTOR (4 downto 0);
    ex_wreg: OUT STD_LOGIC
  );
end id_ex;

ARCHITECTURE behave OF id_ex IS
  SIGNAL ex_aluop_s: STD_LOGIC_VECTOR (7 downto 0);
  SIGNAL ex_alusel_s: STD_LOGIC_VECTOR (2 downto 0);
  SIGNAL ex_reg1_s: STD_LOGIC_VECTOR (31 downto 0);
  SIGNAL ex_reg2_s: STD_LOGIC_VECTOR (31 downto 0);
  SIGNAL ex_wd_s: STD_LOGIC_VECTOR (4 downto 0);
  SIGNAL ex_wreg_s: STD_LOGIC;
BEGIN
PROCESS(clk, rst)
  BEGIN
    if(clk'event and clk='1')then
      if(rst='1')then
        ex_aluop_s <= "00000000";
        ex_alusel_s <= "000";
        ex_reg1_s <= X"00000000";
        ex_reg2_s <= X"00000000";
        ex_wd_s <= "00000";
        ex_wreg_s <= '0';
      else
        ex_aluop_s <= id_aluop;
        ex_alusel_s <= id_alusel;
        ex_reg1_s <= id_reg1;
        ex_reg2_s <= id_reg2;
        ex_wd_s <= id_wd;
        ex_wreg_s <= id_wreg;
    end if;
  end if;
  ex_aluop <= ex_aluop_s;
  ex_alusel <= ex_alusel_s;
  ex_reg1 <= ex_reg1_s;
  ex_reg2 <= ex_reg2_s;
  ex_wd <= ex_wd_s;
  ex_wreg <= ex_wreg_s;
END PROCESS;
END;
