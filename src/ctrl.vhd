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
    stallreq_from_mem: IN STD_LOGIC;
    excepttype_i: IN STD_LOGIC_VECTOR(31 downto 0);
    cp0_epc_i: IN STD_LOGIC_VECTOR(31 downto 0);
    new_pc: OUT STD_LOGIC_VECTOR(31 downto 0);
    flush: OUT STD_LOGIC;
    stall: OUT STD_LOGIC_VECTOR(5 downto 0)
    );
  END ctrl;

ARCHITECTURE arch OF ctrl IS
BEGIN
  PROCESS(rst, stallreq_from_ex, stallreq_from_id, stallreq_from_mem)
    BEGIN
      if (rst = '0') THEN
        stall <= "000000";
        flush <= '0';
        new_pc <= X"00000000";
      ELSIF (stallreq_from_ex = '1') THEN
        stall <= "001111";
        flush <= '1';
        case(excepttype_i) is
          when X"00000001" =>
            new_pc <= X"00000020";
          when X"00000008" =>
            new_pc <= X"00000040";
          when X"0000000a" =>
            new_pc <= X"00000040";
          when X"0000000c" =>
            new_pc <= X"00000040";
          when X"0000000e" =>
            new_pc <= cp0_epc_i;
        end case;
      ELSIF (stallreq_from_id = '1') THEN
        stall <= "000111";
        flush <= '0';
      ELSIF (stallreq_from_mem = '1') THEN
        stall <= "001111";
        flush <= '0';
      ELSE
        stall <= "000000";
        flush <= '0';
        new_pc <= X"00000000";
      END IF;
    END PROCESS;
END ARCHITECTURE; -- arch
