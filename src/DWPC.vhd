LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
use work.CPU32.all;

ENTITY DWPC is
  port(
    rst: in STD_LOGIC;
    clk: in STD_LOGIC;

    inst_data: inout STD_LOGIC_VECTOR(31 downto 0);
    inst_addr: out STD_LOGIC_VECTOR(19 downto 0);
    inst_we: out STD_LOGIC;
    inst_ce: out STD_LOGIC;
    inst_oe: out STD_LOGIC;

    mem_data: inout STD_LOGIC_VECTOR(31 downto 0);
    mem_addr: out STD_LOGIC_VECTOR(19 downto 0);
    mem_we: out STD_LOGIC;
    mem_ce: out STD_LOGIC;
    mem_oe: out STD_LOGIC

    );
end DWPC;

architecture arch of DWPC is

component openmips
port(
  rst: in STD_LOGIC;
  clk: in STD_LOGIC;

  rom_data_i: in STD_LOGIC_VECTOR(31 downto 0);
  rom_addr_o: out STD_LOGIC_VECTOR(31 downto 0);
  rom_ce_o: buffer STD_LOGIC;

  ram_data_i: in STD_LOGIC_VECTOR(31 downto 0);
  ram_addr_o: out STD_LOGIC_VECTOR(31 downto 0);
  ram_data_o: out STD_LOGIC_VECTOR(31 downto 0);
  ram_we_o: out STD_LOGIC;
  ram_sel_o: out STD_LOGIC_VECTOR(3 downto 0);
  ram_ce_o: out STD_LOGIC
  );
end component;

component ram
Port(
  clk: in std_logic;
  rst: in std_logic;
   
  ope_addr: in std_logic_vector(19 downto 0);
  write_data: in std_logic_vector(31 downto 0);
  read_data: out std_logic_vector(31 downto 0);
  ope_we: in std_logic;
  ope_ce: in std_logic;
     
  ram_addr: out std_logic_vector(19 downto 0);
  ram_data: inout std_logic_vector(31 downto 0);
  ram_ce: out std_logic;
  ram_oe: out std_logic;
  ram_we: out std_logic
);
end component;
  
--IF
signal rom_data: STD_LOGIC_VECTOR(31 downto 0);
signal rom_addr: STD_LOGIC_VECTOR(31 downto 0);
signal rom_ce: STD_LOGIC;

-- mem
signal ram_data_o: STD_LOGIC_VECTOR(31 downto 0);
signal ram_addr: STD_LOGIC_VECTOR(31 downto 0);
signal ram_data_i: STD_LOGIC_VECTOR(31 downto 0);
signal ram_we_o: STD_LOGIC;
signal ram_sel_o: STD_LOGIC_VECTOR(3 downto 0);
signal ram_ce_o: STD_LOGIC;

begin
ram_inst: ram port map(
  clk => clk, rst => rst, ope_addr => rom_addr(21 downto 2), write_data => X"00000000", read_data => rom_data, 
  ope_we => '1', ope_ce => rom_ce, ram_addr => inst_addr, ram_data => inst_data, ram_ce => inst_ce, ram_oe => inst_oe,
  ram_we => inst_we
  );

ram_mem: ram port map(
  clk => clk, rst => rst, ope_addr => ram_addr(21 downto 2), write_data => ram_data_o, read_data => ram_data_i,
  ope_we => ram_we_o, ope_ce => ram_ce_o, ram_addr => mem_addr, ram_data => mem_data, ram_ce => mem_ce, ram_oe => mem_oe,
  ram_we => mem_we
  );

cpu: openmips port map(
  rst => rst, clk => clk, rom_data_i => rom_data, rom_addr_o => rom_addr, rom_ce_o => rom_ce,
  ram_data_i => ram_data_i, ram_addr_o => ram_addr, ram_data_o => ram_data_o, ram_we_o =>ram_we_o, ram_sel_o => ram_sel_o,
  ram_ce_o => ram_ce_o
  );

end architecture ; -- arch