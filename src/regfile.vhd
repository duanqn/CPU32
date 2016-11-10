LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY regfile is
  port(
    rst: in STD_LOGIC;
    clk: in STD_LOGIC;
    
    -- 写端口
    we: in STD_LOGIC;
    waddr: in STD_LOGIC_VECTOR(4 downto 0);
    wdata: in STD_LOGIC_VECTOR(31 downto 0);
    
    -- 读端口1
    re1: in STD_LOGIC;
    raddr1: in STD_LOGIC_VECTOR(4 downto 0);
    rdata1: out STD_LOGIC_VECTOR(31 downto 0);

    -- 读端口2
    re2: in STD_LOGIC;
    raddr2: in STD_LOGIC_VECTOR(4 downto 0);
    rdata2: out STD_LOGIC_VECTOR(31 downto 0));
end regfile;

architecture arch of regfile is
  type REGISTERS is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
  signal regs: REGISTERS;
begin

  write_operation : process(clk)
  variable addr: integer;
  begin
    if (clk'event and clk = '1') then
      if (rst = '1') then
        if(we = '1' and waddr /= "00000") then
          case waddr is
            when "00001" => regs(1) <= wdata;
            when "00010" => regs(2) <= wdata;
            when "00011" => regs(3) <= wdata;
            when "00100" => regs(4) <= wdata;
            when "00101" => regs(5) <= wdata;
            when "00110" => regs(6) <= wdata;
            when "00111" => regs(7) <= wdata;
            when "01000" => regs(8) <= wdata;
            when "01001" => regs(9) <= wdata;
            when "01010" => regs(10) <= wdata;
            when "01011" => regs(11) <= wdata;
            when "01100" => regs(12) <= wdata;
            when "01101" => regs(13) <= wdata;
            when "01110" => regs(14) <= wdata;
            when "01111" => regs(15) <= wdata;
            when "10000" => regs(16) <= wdata;
            when "10001" => regs(17) <= wdata;
            when "10010" => regs(18) <= wdata;
            when "10011" => regs(19) <= wdata;
            when "10100" => regs(20) <= wdata;
            when "10101" => regs(21) <= wdata;
            when "10110" => regs(22) <= wdata;
            when "10111" => regs(23) <= wdata;
            when "11000" => regs(24) <= wdata;
            when "11001" => regs(25) <= wdata;
            when "11010" => regs(26) <= wdata;
            when "11011" => regs(27) <= wdata;
            when "11100" => regs(28) <= wdata;
            when "11101" => regs(29) <= wdata;
            when "11110" => regs(30) <= wdata;
            when "11111" => regs(31) <= wdata;
            when others => null;
          end case;
          addr := to_integer(unsigned(waddr));
          regs(addr) <= wdata;
        end if;
      end if;
    end if;
  end process ; -- write_operation

  read_1_operation : process(rst, raddr1, we, re1)
  variable addr: integer;
  begin
    if (rst = '1') then
      rdata1 <= x"00000000";
    elsif (raddr1 = "00000") then
      rdata1 <= x"00000000";
    elsif (raddr1 = waddr and we = '1' and re1 = '1') then
      rdata1 <= wdata;
    elsif (re1 = '1') then
      case raddr1 is
        when "00001" => rdata1 <= regs(1); 
        when "00010" => rdata1 <= regs(2); 
        when "00011" => rdata1 <= regs(3); 
        when "00100" => rdata1 <= regs(4); 
        when "00101" => rdata1 <= regs(5); 
        when "00110" => rdata1 <= regs(6); 
        when "00111" => rdata1 <= regs(7); 
        when "01000" => rdata1 <= regs(8); 
        when "01001" => rdata1 <= regs(9); 
        when "01010" => rdata1 <= regs(10); 
        when "01011" => rdata1 <= regs(11); 
        when "01100" => rdata1 <= regs(12); 
        when "01101" => rdata1 <= regs(13); 
        when "01110" => rdata1 <= regs(14); 
        when "01111" => rdata1 <= regs(15); 
        when "10000" => rdata1 <= regs(16); 
        when "10001" => rdata1 <= regs(17); 
        when "10010" => rdata1 <= regs(18); 
        when "10011" => rdata1 <= regs(19); 
        when "10100" => rdata1 <= regs(20); 
        when "10101" => rdata1 <= regs(21); 
        when "10110" => rdata1 <= regs(22); 
        when "10111" => rdata1 <= regs(23); 
        when "11000" => rdata1 <= regs(24); 
        when "11001" => rdata1 <= regs(25); 
        when "11010" => rdata1 <= regs(26); 
        when "11011" => rdata1 <= regs(27); 
        when "11100" => rdata1 <= regs(28); 
        when "11101" => rdata1 <= regs(29); 
        when "11110" => rdata1 <= regs(30); 
        when "11111" => rdata1 <= regs(31); 
        when others => null;
      end case;
    else
      rdata1 <= x"00000000";
    end if;      
  end process ; -- read_1_operation

  read_2_operation : process(rst, raddr2, we, re2)
  variable addr: integer;
  begin
    if (rst = '1') then
      rdata2 <= x"00000000";
    elsif (raddr2 = "00000") then
      rdata2 <= x"00000000";
    elsif (raddr2 = waddr and we = '1' and re2 = '1') then
      rdata2 <= wdata;
    elsif (re2 = '1') then
      case raddr2 is
        when "00001" => rdata2 <= regs(1); 
        when "00010" => rdata2 <= regs(2); 
        when "00011" => rdata2 <= regs(3); 
        when "00100" => rdata2 <= regs(4); 
        when "00101" => rdata2 <= regs(5); 
        when "00110" => rdata2 <= regs(6); 
        when "00111" => rdata2 <= regs(7); 
        when "01000" => rdata2 <= regs(8); 
        when "01001" => rdata2 <= regs(9); 
        when "01010" => rdata2 <= regs(10); 
        when "01011" => rdata2 <= regs(11); 
        when "01100" => rdata2 <= regs(12); 
        when "01101" => rdata2 <= regs(13); 
        when "01110" => rdata2 <= regs(14); 
        when "01111" => rdata2 <= regs(15); 
        when "10000" => rdata2 <= regs(16); 
        when "10001" => rdata2 <= regs(17); 
        when "10010" => rdata2 <= regs(18); 
        when "10011" => rdata2 <= regs(19); 
        when "10100" => rdata2 <= regs(20); 
        when "10101" => rdata2 <= regs(21); 
        when "10110" => rdata2 <= regs(22); 
        when "10111" => rdata2 <= regs(23); 
        when "11000" => rdata2 <= regs(24); 
        when "11001" => rdata2 <= regs(25); 
        when "11010" => rdata2 <= regs(26); 
        when "11011" => rdata2 <= regs(27); 
        when "11100" => rdata2 <= regs(28); 
        when "11101" => rdata2 <= regs(29); 
        when "11110" => rdata2 <= regs(30); 
        when "11111" => rdata2 <= regs(31); 
        when others => null;
      end case;
    else
      rdata2 <= x"00000000";
    end if;      
  end process ; -- read_2_operation
end architecture ; -- arch

