LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;
use work.CPU32.all;

entity hilo_reg is
  PORT(
    clk:in STD_LOGIC;
    rst:in STD_LOGIC;
    we:in STD_LOGIC;
    hi_i:in STD_LOGIC_VECTOR(31 downto 0);
    lo_i:in STD_LOGIC_VECTOR(31 downto 0);
    hi_o:out STD_LOGIC_VECTOR(31 downto 0);
    lo_o:out STD_LOGIC_VECTOR(31 downto 0)
  );
end hilo_reg;

architecture reg of hilo_reg is

begin
  process(clk)
  variable hi_val:STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
  variable lo_val:STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
  begin
    hi_o <= hi_val;
    lo_o <= lo_val;
    if clk'event and clk = '1' then
      if rst = '0' then
        hi_val := x"00000000";
        lo_val := x"00000000";
      elsif we = '1' then
        hi_val := hi_i;
        lo_val := lo_i;
      end if;
    end if;
  end process;
end reg;
