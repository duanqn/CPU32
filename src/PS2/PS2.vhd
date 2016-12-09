library IEEE;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PS2 is port(
  clk : in std_logic;
  rst : in std_logic;
  ps2clk : in std_logic;                       -- clock in PS2 before dealing with burrs
  ps2data : in std_logic_vector                -- data from PS2 before dealing with burrs
);
end PS2;

architecture behave of PS2 is
signal data : std_logic;                       -- data from PS2 after dealing with burrs
signal clk0 : std_logic;                       -- clock from PS2 after dealing with burrs
signal clk1, clk2 : std_logic;
begin
  process (clk, rst)
    if (rst = '0') then
      clk1 <= '1';
      clk2 <= '1';
      clk0 <= '1';
    elsif (rising_edge(clk)) then
      clk1 <= ps2clk;
      clk2 <= clk1;
    end if;
    clk0 <= (not clk1) and clk2;
  end process;

  process (clk, rst, datain)
    if (rst = '0') then
      data <= '1';
    elsif (rising_edge(clk)) then
      data <= ps2data;
    end if;
  end process;


end behave;
