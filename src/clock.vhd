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
BEGIN

  PROCESS(clk)
    BEGIN
      if(rst = '0') then 
        clk_new <= '0';
      elsif (clk'event and clk = '1') then
        clk_new <= not clk_new; 
      END IF;
    END PROCESS;
END ARCHITECTURE; -- arch