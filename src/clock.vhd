LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL; 
use work.CPU32.all;

ENTITY clock IS
  PORT(
    rst: IN STD_LOGIC;
    clk: IN STD_LOGIC;
    clk_new: BUFFER STD_LOGIC
    );
  END clock;

ARCHITECTURE arch OF clock IS
signal clk_2: STD_LOGIC := 0;
BEGIN

  PROCESS(clk)
    BEGIN
      if(rst = '0') then 
        clk_2 <= '0';
      elsif (clk'event and clk = '1') then
        clk_2 <= not clk_2; 
      END IF;
    END PROCESS;

  PROCESS(clk_2)
    BEGIN
      if(rst = '0') then 
        clk_new <= '0';
      elsif (clk_2'event and clk_2 = '1') then
        clk_new <= not clk_new; 
      END IF;
    END PROCESS;
END ARCHITECTURE; -- arch

