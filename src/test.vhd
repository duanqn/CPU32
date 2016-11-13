library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


entity test is 
  PORT(
    clk: in STD_LOGIC;
    inSignal: in STD_LOGIC;
    outSignal: out STD_LOGIC
  );
end test;

architecture simple of test is
signal keyJ: STD_LOGIC;

begin
  keyJ <= clk after 15ns;

  process(clk， keyJ)
  begin
    if keyJ = '1' then
      outSignal = '1'
    elsif clk'event and clk = '1'  then
      outSignal <= inSignal;
    end if;
  end process;


end simple;