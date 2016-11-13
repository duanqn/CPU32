LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;
use work.CPU32.all;

entity compare is
  PORT(
    data1_i:in STD_LOGIC_VECTOR(31 downto 0);
    data2_i:in STD_LOGIC_VECTOR(31 downto 0);
    equal:out STD_LOGIC;
    less:out STD_LOGIC;
    greater:out STD_LOGIC
  );
end compare;

architecture behave of compare is
signal equals:STD_LOGIC_VECTOR(31 downto 0);
signal lesss:STD_LOGIC_VECTOR(31 downto 0);
signal greaters:STD_LOGIC_VECTOR(31 downto 0);
begin

end behave;
