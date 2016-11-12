LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;
use work.CPU32.all;


ENTITY ex_mem IS
  PORT(
    clk: IN STD_LOGIC;
    rst: IN STD_LOGIC;

    ex_wd: IN STD_LOGIC_VECTOR (4 downto 0);
    ex_wreg: IN STD_LOGIC;
    ex_wdata: IN STD_LOGIC_VECTOR (31 downto 0);
    ex_hi: IN STD_LOGIC_VECTOR (31 downto 0);
    ex_lo: IN STD_LOGIC_VECTOR (31 downto 0);
    ex_whilo: IN STD_LOGIC;
    ex_aluop: IN STD_LOGIC_VECTOR (7 downto 0);
    ex_mem_addr: IN STD_LOGIC_VECTOR (31 downto 0);
    ex_reg2: IN STD_LOGIC_VECTOR (31 downto 0);
    stall: IN STD_LOGIC_VECTOR(5 downto 0);

    mem_wd: OUT STD_LOGIC_VECTOR (4 downto 0);
    mem_wreg: OUT STD_LOGIC;
    mem_wdata: OUT STD_LOGIC_VECTOR (31 downto 0);
    mem_aluop: OUT STD_LOGIC_VECTOR (7 downto 0);
    mem_mem_addr: OUT STD_LOGIC_VECTOR (31 downto 0);
    mem_reg2: OUT STD_LOGIC_VECTOR (31 downto 0);
    mem_hi: OUT STD_LOGIC_VECTOR (31 downto 0);
    mem_lo: OUT STD_LOGIC_VECTOR (31 downto 0);
    mem_whilo: OUT STD_LOGIC
  );
end ex_mem;

  ARCHITECTURE behave OF ex_mem IS
    SIGNAL mem_wd_s: STD_LOGIC_VECTOR (4 downto 0);
    SIGNAL mem_wreg_s: STD_LOGIC;
    SIGNAL mem_wdata_s: STD_LOGIC_VECTOR (31 downto 0);
  BEGIN
    PROCESS(clk, rst)
      BEGIN
        IF (clk'event and clk = '1') THEN
          IF (rst = '1') THEN
            mem_wd_s <= "00000";
            mem_wreg_s <= '0';
            mem_wdata_s <= X"00000000";
            mem_hi <= X"00000000";
            mem_lo <= X"00000000";
            mem_whilo <= '0';
          ELSIF (stall(3) = '1' and stall(4) = '0') THEN
            mem_wd_s <= "00000";
            mem_wreg_s <= '0';
            mem_wdata_s <= X"00000000";
            mem_hi <= X"00000000";
            mem_lo <= X"00000000";
            mem_whilo <= '0';
          ELSIF (stall(3) = '0') THEN
            mem_wd_s <= ex_wd;
            mem_wreg_s <= ex_wreg;
            mem_wdata_s <= ex_wdata;
            mem_hi <= ex_hi;
            mem_lo <= ex_lo;
            mem_whilo <= ex_whilo;
            mem_aluop <= ex_aluop;
            mem_mem_addr <= ex_mem_addr;
            mem_reg2 <= ex_reg2;
          END IF;
        END IF;
        mem_wd <= mem_wd_s;
        mem_wreg <= mem_wreg_s;
        mem_wdata <= mem_wdata_s;
      END PROCESS;
    END;
