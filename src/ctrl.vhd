LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL; 
use work.CPU32.all;

ENTITY ctrl IS
  PORT(
    rst: IN STD_LOGIC;
    stallreq_from_id: IN STD_LOGIC;
    stallreq_from_ex: IN STD_LOGIC;
    stall: OUT STD_LOGIC_VECTOR(5 downto 0)
    );
  END ctrl;

ARCHITECTURE arch OF ctrl IS
BEGIN
  PROCESS(rst, stallreq_from_ex, stallreq_from_id)
    BEGIN
      if (rst = '0') THEN
        stall <= "000000";
      ELSIF (stallreq_from_ex = '1') THEN
        stall <= "001111";
      ELSIF (stallreq_from_id = '1') THEN
        stall <= "000111";
      ELSE 
        stall <= "000000";
      END IF;
    END PROCESS;
END ARCHITECTURE; -- arch