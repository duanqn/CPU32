LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL; 
use work.CPU32.all;

ENTITY clock IS
  PORT(
    rst: IN STD_LOGIC;
    clk: IN STD_LOGIC;
    clk_new: OUT STD_LOGIC
    );
  END clock;

ARCHITECTURE arch OF ctrl IS
signal clks: STD_LOGIC_VECTOR(1 downto 0) := "00";
BEGIN

  PROCESS(clks)
    BEGIN
      if (rst = '0') THEN
        clks <= "00";
      ELSIF rising_edge(clk) THEN
        clks <= clks - 1;
      END IF;
    END PROCESS;

    clk_new <= clks(1); 
END ARCHITECTURE; -- arch