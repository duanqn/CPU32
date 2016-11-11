library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.CPU32.all;


entity pc_reg is
  PORT(
    clk: in STD_LOGIC;
    rst: in STD_LOGIC;
    stall: in STD_LOGIC_VECTOR(5 downto 0);
    pc: buffer STD_LOGIC_VECTOR(31 downto 0);
    ce: buffer STD_LOGIC
  );
end pc_reg;

architecture counter of pc_reg is
signal counter:STD_LOGIC_VECTOR(31 downto 0) := x"00000000";

begin
  process(clk)
  begin
    if (clk'event and clk = '1') then
      if (rst = '1') then
        ce <= '0';
      else
        ce <= '1';
      end if;
    end if;
  end process;

  PROCESS(clk)
  begin
    if (clk'event and clk = '1') then
      if (ce = '0') then
        pc <= x"00000000";
      elsif (stall(0) = '0') then 
        pc <= pc + x"00000004";
      END if;
    end if;
  end PROCESS;
end counter;
