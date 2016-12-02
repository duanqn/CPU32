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
    cp0_ebase_i: IN STD_LOGIC_VECTOR(31 downto 0);
    new_pc: OUT STD_LOGIC_VECTOR(31 downto 0);
    flush: OUT STD_LOGIC;
    stall: OUT STD_LOGIC_VECTOR(5 downto 0)
    );
  END ctrl;

ARCHITECTURE arch OF ctrl IS
BEGIN
  PROCESS(rst, stallreq_from_ex, stallreq_from_id, stallreq_from_mem, excepttype_i, cp0_ebase_i, cp0_epc_i)
    BEGIN
      if (rst = '0') THEN
        stall <= "000000";
        flush <= '0';
        new_pc <= X"00000000";
      ELSIF (excepttype_i /= X"00000000") THEN
        stall <= "000000";
        flush <= '1';
        case(excepttype_i) is
          when X"00000002" =>  -- TLBL
            new_pc <= "10"&cp0_ebase_i(29 downto 12) & "000000000000";
          when X"00000003" =>  -- TLBS
            new_pc <= "10"&cp0_ebase_i(29 downto 12) & "000000000000";
          when x"0000000E" => -- ERET
            new_pc <= cp0_epc_i;
          when others =>
            new_pc <= "10"&cp0_ebase_i(29 downto 12) & "000110000000";
        end case;
      ELSIF (stallreq_from_ex = '1') THEN
        stall <= "001111";
        flush <= '0';
        new_pc <= X"00000000";
      ELSIF (stallreq_from_id = '1') THEN
        stall <= "000111";
        flush <= '0';
        new_pc <= X"00000000";
      ELSIF (stallreq_from_mem = '1') THEN
        stall <= "111111";
        flush <= '0';
        new_pc <= X"00000000";
      ELSE
        stall <= "000000";
        flush <= '0';
        new_pc <= X"00000000";
      END IF;
    END PROCESS;
END ARCHITECTURE; -- arch
