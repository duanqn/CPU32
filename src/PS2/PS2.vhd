library IEEE;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PS2 is port(
  clk : in std_logic;
  rst : in std_logic;
  clkin : in std_logic;                         -- clock in PS2
  datain : in std_logic_vector                  -- data from PS2
  ps2clk : in std_logic;                       -- clock in PS2 after dealing with burrs
  ps2data : in std_logic_vector                -- data from PS2 after dealing with burrs
);
end PS2;

architecture behave of PS2 is
signal data : std_logic;
signal clk1, clk2 : std_logic;
begin
  process (clk, rst)
    if (rst = '0') then
      clk1 <= '0';
      clk2 <= '0';
      clk <= '0';
    elsif (rising_edge(clk)) then
      clk1 <= ps2clk;
      clk2 <= clk1;
    end if;
  end process
end behave;
