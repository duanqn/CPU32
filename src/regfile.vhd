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
      addr := to_integer(unsigned(raddr1));
      rdata1 <= regs(addr);
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
      addr := to_integer(unsigned(raddr2));
      rdata2 <= regs(addr);
    else
      rdata2 <= x"00000000";
    end if;      
  end process ; -- read_2_operation
end architecture ; -- arch

