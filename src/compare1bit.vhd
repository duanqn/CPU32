LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;
use work.CPU32.all;

entity compare1bit is
  PORT(
    data1_i:in STD_LOGIC;
    data2_i:in STD_LOGIC;
    equal:out STD_LOGIC;
    less:out STD_LOGIC;
    greater:out STD_LOGIC
  );
end compare1bit;

architecture behave of compare1bit is
signal not1:STD_LOGIC;
signal not2:STD_LOGIC;
begin
  not1 <= not data1_i;
  not2 <= not data2_i;
  equal <= (data1_i and data2_i) or (not1 and not2);
  less <= not1 and data2_i;
  greater <= data1_i and not2;
end behave;
