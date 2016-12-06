library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.CPU32.all;


entity pc_reg is
  PORT(
    clk: in STD_LOGIC;
    rst: in STD_LOGIC;
    stall: in STD_LOGIC_VECTOR(5 downto 0);
    branch_flag_i: in STD_LOGIC;
    branch_target_address_i: in STD_LOGIC_VECTOR(31 downto 0);
    flush: in STD_LOGIC;
    new_pc: in STD_LOGIC_VECTOR(31 downto 0);

    pc: buffer STD_LOGIC_VECTOR(31 downto 0);
    ce: buffer STD_LOGIC
  );
end pc_reg;

architecture counter of pc_reg is

begin
  process(clk)
  begin
    if (clk'event and clk = '1') then
      if (rst = '0') then
        ce <= '0';
      else
        ce <= '1';
      end if;
    end if;
  end process;

  PROCESS(clk)
  begin
    if (clk'event and clk = '1') then
      if (ce = '0') then
        pc <= x"80000000";
      elsif (flush = '1') then
        pc <= new_pc;
      elsif (stall(0) = '0') then
        if (branch_flag_i = '1') then
          pc <= branch_target_address_i;
        else
          pc <= pc + x"00000004";
        end if;
      end if;
    end if;
  end PROCESS;
end counter;
