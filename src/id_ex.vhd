LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;
use work.CPU32.all;


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
    stall: IN STD_LOGIC_VECTOR(5 downto 0);

    id_link_address: IN STD_LOGIC_VECTOR(31 downto 0);
    id_is_in_delayslot: IN STD_LOGIC;
    next_inst_in_delayslot_i: IN STD_LOGIC;

    id_inst:in STD_LOGIC_VECTOR(31 downto 0);
    ex_inst:out STD_LOGIC_VECTOR(31 downto 0);

    ex_aluop: OUT STD_LOGIC_VECTOR (7 downto 0);
    ex_alusel: OUT STD_LOGIC_VECTOR (2 downto 0);
    ex_reg1: OUT STD_LOGIC_VECTOR (31 downto 0);
    ex_reg2: OUT STD_LOGIC_VECTOR (31 downto 0);
    ex_wd: OUT STD_LOGIC_VECTOR (4 downto 0);
    ex_wreg: OUT STD_LOGIC;

    ex_link_address: OUT STD_LOGIC_VECTOR(31 downto 0);
    ex_is_in_delayslot: OUT STD_LOGIC;
    is_in_delayslot_o: OUT STD_LOGIC
  );
end id_ex;

ARCHITECTURE behave OF id_ex IS
BEGIN
PROCESS(clk, rst)
  BEGIN
    if (clk'event and clk = '1') then
      if (rst = '1') then
        ex_aluop <= "00000000";
        ex_alusel <= "000";
        ex_reg1 <= X"00000000";
        ex_reg2 <= X"00000000";
        ex_wd <= "00000";
        ex_wreg <= '0';
      elsif (stall(2) = '1' and stall(3) = '0') then
        ex_aluop <= "00000000";
        ex_alusel <= "000";
        ex_reg1 <= X"00000000";
        ex_reg2 <= X"00000000";
        ex_wd <= "00000";
        ex_wreg <= '0';
      elsif (stall(2) = '0') then
        ex_aluop <= id_aluop;
        ex_alusel <= id_alusel;
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_wd <= id_wd;
        ex_wreg <= id_wreg;
        ex_link_address <= id_link_address;
        ex_is_in_delayslot <= id_is_in_delayslot;
        is_in_delayslot_o <= next_inst_in_delayslot_i;

        ex_inst <= id_inst;
      end if;
    end if;
  END PROCESS;
END;
