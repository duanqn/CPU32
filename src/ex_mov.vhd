LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL; 

ENTITY ex IS
  PORT(
    rst: IN STD_LOGIC;

    aluop_i: IN STD_LOGIC_VECTOR(7 downto 0);
    alusel_i: IN STD_LOGIC_VECTOR(2 downto 0);
    reg1_i: IN STD_LOGIC_VECTOR(31 downto 0);
    reg2_i: IN STD_LOGIC_VECTOR(31 downto 0);
    wd_i: IN STD_LOGIC_VECTOR(4 downto 0);
    wreg_i: IN STD_LOGIC;

    hi_i: IN STD_LOGIC_VECTOR(31 downto 0);
    lo_i: IN STD_LOGIC_VECTOR(31 downto 0);
    wb_hi_i: IN STD_LOGIC_VECTOR(31 downto 0);
    wb_lo_i: IN STD_LOGIC_VECTOR(31 downto 0);
    wb_whilo_i: IN STD_LOGIC;
    mem_hi_i: IN STD_LOGIC_VECTOR(31 downto 0);
    mem_lo_i: IN STD_LOGIC_VECTOR(31 downto 0);
    mem_whilo_i: IN STD_LOGIC;

    hi_o: OUT STD_LOGIC_VECTOR(31 downto 0);
    lo_o: OUT STD_LOGIC_VECTOR(31 downto 0);
    whilo_o: OUT STD_LOGIC;

    wd_o: OUT STD_LOGIC_VECTOR(4 downto 0);
    wreg_o: OUT STD_LOGIC;
    wdata_o: OUT STD_LOGIC_VECTOR(31 downto 0)

  );
end ex;

  ARCHITECTURE behave OF ex IS

    SIGNAL logicout: STD_LOGIC_VECTOR(31 downto 0);
    SIGNAL shiftres: STD_LOGIC_VECTOR(31 downto 0);
    SIGNAL moveres: STD_LOGIC_VECTOR(31 downto 0);
    SIGNAL HI STD_LOGIC_VECTOR(31 downto 0);
    SIGNAL LO STD_LOGIC_VECTOR(31 downto 0);

    -- macro
    CONSTANT EXE_OR_OP: STD_LOGIC_VECTOR(7 downto 0) := "00100101";
    CONSTANT EXE_NOP_OP: STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    CONSTANT EXE_AND_OP: STD_LOGIC_VECTOR(7 downto 0) := "00100100";
    CONSTANT EXE_NOR_OP: STD_LOGIC_VECTOR(7 downto 0) := "00100111";
    CONSTANT EXE_XOR_OP: STD_LOGIC_VECTOR(7 downto 0) := "00100110";
    CONSTANT EXE_SLL_OP: STD_LOGIC_VECTOR(7 downto 0) := "00000100";
    CONSTANT EXE_SRL_OP: STD_LOGIC_VECTOR(7 downto 0) := "00000110";
    CONSTANT EXE_SRA_OP: STD_LOGIC_VECTOR(7 downto 0) := "00000111";
    CONSTANT EXE_RES_LOGIC: STD_LOGIC_VECTOR(2 downto 0) := "001";
    CONSTANT EXE_RES_NOP: STD_LOGIC_VECTOR(2 downto 0) := "000";
    CONSTANT EXE_RES_SHIFT: STD_LOGIC_VECTOR(2 downto 0) := "010";

  BEGIN

-- get HI and LO reg
    PROCESS(rst, mem_lo_i, mem_hi_i, mem_whilo_i, wb_hi_i, wb_lo_i, wb_whilo_i, hi_o, hi_i)
      BEGIN
        IF(rst = '1') THEN
          HI <= X"00000000";
          LO <= X"00000000";
        ELSIF (mem_whilo_i = '1') THEN
          HI <= mem_hi_i;
          LO <= mem_lo_i;
        ELSIF (wb_whilo_i = '1') THEN
          HI <= wb_hi_i;
          LO <= wb_lo_i;
        ELSE
          HI <= hi_i;
          LO <= lo_i;
        END IF;
      END PROCESS;

-- about MFHI, MFLO
    PROCESS(rst, aluop_i)
      BEGIN
        IF(rst = '1') THEN
          moveres <= X"00000000";
        ELSE
          CASE aluop_i IS
            WHEN EXE_MFHI_OP => moveres <= HI;
            WHEN EXE_MFLO_OP => moveres <= LO;
            WHEN others => moveres <= X"00000000";
          END CASE;
        END IF;
      END PROCESS;

-- about MTLO, MTHI
    PROCESS(rst, aluop_i, reg1_i)
      BEGIN
        IF(rst = '1') THEN
          whilo_o <= '0';
          hi_o <= X"00000000";
          lo_o <= X"00000000";
        ELSIF

-- get logicOut
    PROCESS(rst, aluop_i, reg2_i, reg1_i)
      BEGIN
        IF(rst = '1') THEN
          logicout <= X"00000000";
        ELSE
          CASE aluop_i IS
            WHEN EXE_OR_OP => logicout <= reg1_i OR reg2_i;
            WHEN EXE_AND_OP => logicout <= reg1_i AND reg2_i;
            WHEN EXE_NOR_OP => logicout <= NOT (reg1_i or reg2_i);
            WHEN EXE_XOR_OP => logicout <= reg1_i XOR reg2_i;
            WHEN others=>logicout<=X"00000000";
          END CASE;
        END IF;
      END PROCESS;

-- get shiftRes
    PROCESS(rst, aluop_i, reg1_i, reg2_i)
      BEGIN
        IF(rst = '1') THEN
          shiftres <= X"00000000";
        ELSE
          CASE aluop_i IS
            WHEN EXE_SLL_OP => 
              CASE reg1_i(4 downto 0) is
                when "00001" => shiftres <= reg2_i(30 downto 0) & '0';
                when "00010" => shiftres <= reg2_i(29 downto 0) & "00"; 
                when "00011" => shiftres <= reg2_i(28 downto 0) & "000"; 
                when "00100" => shiftres <= reg2_i(27 downto 0) & "0000"; 
                when "00101" => shiftres <= reg2_i(26 downto 0) & "00000"; 
                when "00110" => shiftres <= reg2_i(25 downto 0) & "000000"; 
                when "00111" => shiftres <= reg2_i(24 downto 0) & "0000000"; 
                when "01000" => shiftres <= reg2_i(23 downto 0) & "00000000"; 
                when "01001" => shiftres <= reg2_i(22 downto 0) & "000000000"; 
                when "01010" => shiftres <= reg2_i(21 downto 0) & "0000000000"; 
                when "01011" => shiftres <= reg2_i(20 downto 0) & "00000000000"; 
                when "01100" => shiftres <= reg2_i(19 downto 0) & "000000000000"; 
                when "01101" => shiftres <= reg2_i(18 downto 0) & "0000000000000"; 
                when "01110" => shiftres <= reg2_i(17 downto 0) & "00000000000000"; 
                when "01111" => shiftres <= reg2_i(16 downto 0) & "000000000000000"; 
                when "10000" => shiftres <= reg2_i(15 downto 0) & "0000000000000000"; 
                when "10001" => shiftres <= reg2_i(14 downto 0) & "00000000000000000"; 
                when "10010" => shiftres <= reg2_i(13 downto 0) & "000000000000000000"; 
                when "10011" => shiftres <= reg2_i(12 downto 0) & "0000000000000000000"; 
                when "10100" => shiftres <= reg2_i(11 downto 0) & "00000000000000000000"; 
                when "10101" => shiftres <= reg2_i(10 downto 0) & "000000000000000000000"; 
                when "10110" => shiftres <= reg2_i(9 downto 0) & "0000000000000000000000"; 
                when "10111" => shiftres <= reg2_i(8 downto 0) & "00000000000000000000000"; 
                when "11000" => shiftres <= reg2_i(7 downto 0) & "000000000000000000000000"; 
                when "11001" => shiftres <= reg2_i(6 downto 0) & "0000000000000000000000000"; 
                when "11010" => shiftres <= reg2_i(5 downto 0) & "00000000000000000000000000"; 
                when "11011" => shiftres <= reg2_i(4 downto 0) & "000000000000000000000000000"; 
                when "11100" => shiftres <= reg2_i(3 downto 0) & "0000000000000000000000000000"; 
                when "11101" => shiftres <= reg2_i(2 downto 0) & "00000000000000000000000000000"; 
                when "11110" => shiftres <= reg2_i(1 downto 0) & "000000000000000000000000000000"; 
                when "11111" => shiftres <= reg2_i(0 downto 0) & "0000000000000000000000000000000";
                when others => null;
              END CASE;
            WHEN EXE_SRL_OP => 
              CASE reg1_i(4 downto 0) is
                when "00001" => shiftres <= "0" & reg2_i(31 downto 1);
                when "00010" => shiftres <= "00" & reg2_i(31 downto 2); 
                when "00011" => shiftres <= "000" & reg2_i(31 downto 3); 
                when "00100" => shiftres <= "0000" & reg2_i(31 downto 4); 
                when "00101" => shiftres <= "00000" & reg2_i(31 downto 5); 
                when "00110" => shiftres <= "000000" & reg2_i(31 downto 6); 
                when "00111" => shiftres <= "0000000" & reg2_i(31 downto 7); 
                when "01000" => shiftres <= "00000000" & reg2_i(31 downto 8); 
                when "01001" => shiftres <= "000000000" & reg2_i(31 downto 9); 
                when "01010" => shiftres <= "0000000000" & reg2_i(31 downto 10); 
                when "01011" => shiftres <= "00000000000" & reg2_i(31 downto 11); 
                when "01100" => shiftres <= "000000000000" & reg2_i(31 downto 12); 
                when "01101" => shiftres <= "0000000000000" & reg2_i(31 downto 13); 
                when "01110" => shiftres <= "00000000000000" & reg2_i(31 downto 14); 
                when "01111" => shiftres <= "000000000000000" & reg2_i(31 downto 15); 
                when "10000" => shiftres <= "0000000000000000" & reg2_i(31 downto 16); 
                when "10001" => shiftres <= "00000000000000000" & reg2_i(31 downto 17); 
                when "10010" => shiftres <= "000000000000000000" & reg2_i(31 downto 18); 
                when "10011" => shiftres <= "0000000000000000000" & reg2_i(31 downto 19); 
                when "10100" => shiftres <= "00000000000000000000" & reg2_i(31 downto 20); 
                when "10101" => shiftres <= "000000000000000000000" & reg2_i(31 downto 21); 
                when "10110" => shiftres <= "0000000000000000000000" & reg2_i(31 downto 22); 
                when "10111" => shiftres <= "00000000000000000000000" & reg2_i(31 downto 23); 
                when "11000" => shiftres <= "000000000000000000000000" & reg2_i(31 downto 24); 
                when "11001" => shiftres <= "0000000000000000000000000" & reg2_i(31 downto 25); 
                when "11010" => shiftres <= "00000000000000000000000000" & reg2_i(31 downto 26); 
                when "11011" => shiftres <= "000000000000000000000000000" & reg2_i(31 downto 27); 
                when "11100" => shiftres <= "0000000000000000000000000000" & reg2_i(31 downto 28); 
                when "11101" => shiftres <= "00000000000000000000000000000" & reg2_i(31 downto 29); 
                when "11110" => shiftres <= "000000000000000000000000000000" & reg2_i(31 downto 30); 
                when "11111" => shiftres <= "0000000000000000000000000000000" & reg2_i(31 downto 31); 
                when others => null;
              END CASE;
            WHEN EXE_SRA_OP => 
              CASE reg1_i(4 downto 0) is 
                when "00001" => 
                  if reg2_i(31) = '0' then shiftres <= "0" & reg2_i(31 downto 1);
                  ELSE shiftres  <= "1" & reg2_i(31 downto 1);
                  END if;
                when "00010" => 
                  if reg2_i(31) = '0' then shiftres <= "00" & reg2_i(31 downto 2); 
                  ELSE shiftres  <= "11" & reg2_i(31 downto 2); 
                  END if;
                when "00011" => 
                  if reg2_i(31) = '0' then shiftres <= "000" & reg2_i(31 downto 3); 
                  ELSE shiftres  <= "111" & reg2_i(31 downto 3); 
                  END if;
                when "00100" => 
                  if reg2_i(31) = '0' then shiftres <= "0000" & reg2_i(31 downto 4); 
                  ELSE shiftres  <= "1111" & reg2_i(31 downto 4); 
                  END if;
                when "00101" => 
                  if reg2_i(31) = '0' then shiftres <= "00000" & reg2_i(31 downto 5); 
                  ELSE shiftres  <= "11111" & reg2_i(31 downto 5); 
                  END if;
                when "00110" => 
                  if reg2_i(31) = '0' then shiftres <= "000000" & reg2_i(31 downto 6); 
                  ELSE shiftres  <= "111111" & reg2_i(31 downto 6); 
                  END if;
                when "00111" => 
                  if reg2_i(31) = '0' then shiftres <= "0000000" & reg2_i(31 downto 7); 
                  ELSE shiftres  <= "1111111" & reg2_i(31 downto 7); 
                  END if;
                when "01000" => 
                  if reg2_i(31) = '0' then shiftres <= "00000000" & reg2_i(31 downto 8); 
                  ELSE shiftres  <= "11111111" & reg2_i(31 downto 8); 
                  END if;
                when "01001" => 
                  if reg2_i(31) = '0' then shiftres <= "000000000" & reg2_i(31 downto 9); 
                  ELSE shiftres  <= "111111111" & reg2_i(31 downto 9); 
                  END if;
                when "01010" => 
                  if reg2_i(31) = '0' then shiftres <= "0000000000" & reg2_i(31 downto 10); 
                  ELSE shiftres  <= "1111111111" & reg2_i(31 downto 10); 
                  END if;
                when "01011" => 
                  if reg2_i(31) = '0' then shiftres <= "00000000000" & reg2_i(31 downto 11); 
                  ELSE shiftres  <= "11111111111" & reg2_i(31 downto 11); 
                  END if;
                when "01100" => 
                  if reg2_i(31) = '0' then shiftres <= "000000000000" & reg2_i(31 downto 12); 
                  ELSE shiftres  <= "111111111111" & reg2_i(31 downto 12); 
                  END if;
                when "01101" => 
                  if reg2_i(31) = '0' then shiftres <= "0000000000000" & reg2_i(31 downto 13); 
                  ELSE shiftres  <= "1111111111111" & reg2_i(31 downto 13); 
                  END if;
                when "01110" => 
                  if reg2_i(31) = '0' then shiftres <= "00000000000000" & reg2_i(31 downto 14); 
                  ELSE shiftres  <= "11111111111111" & reg2_i(31 downto 14); 
                  END if;
                when "01111" => 
                  if reg2_i(31) = '0' then shiftres <= "000000000000000" & reg2_i(31 downto 15); 
                  ELSE shiftres  <= "111111111111111" & reg2_i(31 downto 15); 
                  END if;
                when "10000" => 
                  if reg2_i(31) = '0' then shiftres <= "0000000000000000" & reg2_i(31 downto 16); 
                  ELSE shiftres  <= "1111111111111111" & reg2_i(31 downto 16); 
                  END if;
                when "10001" => 
                  if reg2_i(31) = '0' then shiftres <= "00000000000000000" & reg2_i(31 downto 17); 
                  ELSE shiftres  <= "11111111111111111" & reg2_i(31 downto 17); 
                  END if;
                when "10010" => 
                  if reg2_i(31) = '0' then shiftres <= "000000000000000000" & reg2_i(31 downto 18); 
                  ELSE shiftres  <= "111111111111111111" & reg2_i(31 downto 18); 
                  END if;
                when "10011" => 
                  if reg2_i(31) = '0' then shiftres <= "0000000000000000000" & reg2_i(31 downto 19); 
                  ELSE shiftres  <= "1111111111111111111" & reg2_i(31 downto 19); 
                  END if;
                when "10100" => 
                  if reg2_i(31) = '0' then shiftres <= "00000000000000000000" & reg2_i(31 downto 20); 
                  ELSE shiftres  <= "11111111111111111111" & reg2_i(31 downto 20); 
                  END if;
                when "10101" => 
                  if reg2_i(31) = '0' then shiftres <= "000000000000000000000" & reg2_i(31 downto 21); 
                  ELSE shiftres  <= "111111111111111111111" & reg2_i(31 downto 21); 
                  END if;
                when "10110" => 
                  if reg2_i(31) = '0' then shiftres <= "0000000000000000000000" & reg2_i(31 downto 22); 
                  ELSE shiftres  <= "1111111111111111111111" & reg2_i(31 downto 22); 
                  END if;
                when "10111" => 
                  if reg2_i(31) = '0' then shiftres <= "00000000000000000000000" & reg2_i(31 downto 23); 
                  ELSE shiftres  <= "11111111111111111111111" & reg2_i(31 downto 23); 
                  END if;
                when "11000" => 
                  if reg2_i(31) = '0' then shiftres <= "000000000000000000000000" & reg2_i(31 downto 24); 
                  ELSE shiftres  <= "111111111111111111111111" & reg2_i(31 downto 24); 
                  END if;
                when "11001" => 
                  if reg2_i(31) = '0' then shiftres <= "0000000000000000000000000" & reg2_i(31 downto 25); 
                  ELSE shiftres  <= "1111111111111111111111111" & reg2_i(31 downto 25); 
                  END if;
                when "11010" => 
                  if reg2_i(31) = '0' then shiftres <= "00000000000000000000000000" & reg2_i(31 downto 26); 
                  ELSE shiftres  <= "11111111111111111111111111" & reg2_i(31 downto 26); 
                  END if;
                when "11011" => 
                  if reg2_i(31) = '0' then shiftres <= "000000000000000000000000000" & reg2_i(31 downto 27); 
                  ELSE shiftres  <= "111111111111111111111111111" & reg2_i(31 downto 27); 
                  END if;
                when "11100" => 
                  if reg2_i(31) = '0' then shiftres <= "0000000000000000000000000000" & reg2_i(31 downto 28); 
                  ELSE shiftres  <= "1111111111111111111111111111" & reg2_i(31 downto 28); 
                  END if;
                when "11101" => 
                  if reg2_i(31) = '0' then shiftres <= "00000000000000000000000000000" & reg2_i(31 downto 29); 
                  ELSE shiftres  <= "11111111111111111111111111111" & reg2_i(31 downto 29); 
                  END if;
                when "11110" => 
                  if reg2_i(31) = '0' then shiftres <= "000000000000000000000000000000" & reg2_i(31 downto 30); 
                  ELSE shiftres  <= "111111111111111111111111111111" & reg2_i(31 downto 30); 
                  END if;
                when "11111" => 
                  if reg2_i(31) = '0' then shiftres <= "0000000000000000000000000000000" & reg2_i(31 downto 31); 
                  ELSE shiftres  <= "1111111111111111111111111111111" & reg2_i(31 downto 31); 
                  END if;
                when others => null;
              END CASE;
            WHEN others => shiftres <= X"00000000";
          END CASE;
        END IF;
      END PROCESS;

    PROCESS(alusel_i, wd_i, wreg_i)
      BEGIN
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        CASE alusel_i IS
          WHEN EXE_RES_LOGIC => wdata_o <= logicout;
          WHEN EXE_RES_SHIFT => wdata_o <= shiftres;
          WHEN EXE_RES_MOVE => wdata_o <= moveres;
          WHEN others => wdata_o <= X"00000000";
        END CASE;
      END PROCESS;
  END;

