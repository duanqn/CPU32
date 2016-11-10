library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pc_reg is
  PORT(
    clk:in STD_LOGIC;
    rst:in STD_LOGIC;
    pc:out STD_LOGIC_VECTOR(31 downto 0);
    ce:out STD_LOGIC
  );
end pc_reg;

architecture counter of pc_reg is
signal counter:STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
  
begin
  pc <= counter;
  process(clk)
  variable ce_var:STD_LOGIC :='0';
  begin
    if clk'event and clk='1' then
      if rst = '1' then
        ce_var := '0';
      else
        ce_var := '1';
      end if;
      ce<=ce_var;
      if ce_var = '1' then
        counter <= x"00000000";
      else
        counter <= counter + x"00000001";
      end if;
    end if;
  end process;
end counter;