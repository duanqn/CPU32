library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.CPU32.all;


entity if_id is
  PORT(
    clk:in STD_LOGIC;
    rst:in STD_LOGIC;
    if_pc:in STD_LOGIC_VECTOR(31 downto 0);
    if_inst:in STD_LOGIC_VECTOR(31 downto 0);
    stall: in STD_LOGIC_VECTOR(5 downto 0);
    id_pc:out STD_LOGIC_VECTOR(31 downto 0);
    id_inst:out STD_LOGIC_VECTOR(31 downto 0)
  );
end if_id;

architecture simple of if_id is

begin
  process(clk)
  begin
    if clk'event and clk = '1' then
      if rst = '1' then
        id_pc <= x"00000000";
        id_inst <= x"00000000";
      elsif (stall(1) = '1' and stall(2) = '0') then
        id_pc <= x"00000000";
        id_inst <= x"00000000";
      elsif (stall(1) = '0') then
        id_pc <= if_pc;
        id_inst <= if_inst;
      else
        -- Never need this but we should cover all possibilities
        id_pc <= x"00000000";
        id_inst <= x"00000000";
      end if;
    end if;
  end process;
end simple;
