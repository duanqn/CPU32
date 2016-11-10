LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY mem is
	port(rst: in STD_LOGIC;
		-- 执行阶段的信号
		wd_i: in STD_LOGIC_VECTOR(4 downto 0);
		wreg_i: in STD_LOGIC;
		wdata_i: in STD_LOGIC_VECTOR(31 downto 0);
		-- 访存阶段结果
    wd_o: out STD_LOGIC_VECTOR(4 downto 0);
    wreg_o: out STD_LOGIC;
    wdata_o: out STD_LOGIC_VECTOR(31 downto 0));
end mem;

architecture arch of mem is
  --signal 
begin
  identifier : process( rst, wd_i, wreg_i, wdata_i )
  begin
    if(rst='1') then 
      wd_o <= "00000";
      wreg_o <= '0';
      wdata_o <= x"00000000";
    else
      wd_o <= wd_i;
      wreg_o <= wreg_i;
      wdata_o <= wdata_i;
    end if;  
  end process ; -- identifier

end architecture ; -- arch

