LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY mem_wb is
  port(
    rst: in STD_LOGIC;
    clk: in STD_LOGIC;
    -- input
    mem_wd: in STD_LOGIC_VECTOR(4 downto 0);
    mem_wreg: in STD_LOGIC;
    mem_wdata: in STD_LOGIC_VECTOR(31 downto 0);
    mem_hi: in STD_LOGIC_VECTOR(31 downto 0);
    mem_lo: in STD_LOGIC_VECTOR(31 downto 0);
    mem_whilo: in STD_LOGIC;
    
    -- output
	  wb_wd: out STD_LOGIC_VECTOR(4 downto 0);
    wb_wreg: out STD_LOGIC;
    wb_wdata: out STD_LOGIC_VECTOR(31 downto 0);
    wb_hi: out STD_LOGIC_VECTOR(31 downto 0);
    wb_lo: out STD_LOGIC_VECTOR(31 downto 0);
    wb_whilo: out STD_LOGIC
    );

end mem_wb;

architecture arch of mem_wb is
  --signal 
begin
  identifier : process(clk)
  begin
    if (clk'event and clk = '1') then
      if (rst = '1') then
        wb_wd <= "00000";
        wb_wreg <= '0';
        wb_wdata <= x"00000000";
        wb_hi <= x"00000000";
        wb_lo <= x"00000000";
        wb_whilo <= '0';
      else
        wb_wd <= mem_wd;
        wb_wreg <= mem_wreg;
        wb_wdata <= mem_wdata;
        wb_hi <= mem_hi;
        wb_lo <= mem_lo;
        wb_whilo <= mem_whilo;
      end if;
    end if;  
  end process ; -- identifier

end architecture ; -- arch

