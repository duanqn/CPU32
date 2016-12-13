LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
use work.CPU32.all;

ENTITY DWPC is
  port(
    rst: in STD_LOGIC;
    clk: in STD_LOGIC;

    baseram_addr: out std_logic_vector(19 downto 0);
    baseram_data: inout std_logic_vector(31 downto 0);
    baseram_ce: out std_logic;
    baseram_oe: out std_logic;
    baseram_we: out std_logic;
	  debug_pc: out std_logic_vector(31 downto 0);
    debug_inst_valid: out std_logic;

    debug_data: out STD_LOGIC_VECTOR(15 downto 0);

    extraram_addr: out std_logic_vector(19 downto 0);
    extraram_data: inout std_logic_vector(31 downto 0);
    extraram_ce: out std_logic;
    extraram_oe: out std_logic;
    extraram_we: out std_logic;

    flash_addr : out  STD_LOGIC_VECTOR (22 downto 0);
    flash_data : inout  STD_LOGIC_VECTOR (15 downto 0);
    flash_control_ce0 : out  STD_LOGIC;
    flash_control_ce1 : out  STD_LOGIC;
    flash_control_ce2 : out  STD_LOGIC;
    flash_control_byte : out  STD_LOGIC;
    flash_control_vpen : out  STD_LOGIC;
    flash_control_rp : out  STD_LOGIC;
    flash_control_oe : out  STD_LOGIC;
    flash_control_we : out  STD_LOGIC;

    serialport_txd : out STD_LOGIC;
    serialport_rxd : in STD_LOGIC

    );
end DWPC;

architecture arch of DWPC is

component openmips
port(
  rst: in STD_LOGIC;
  clk: in STD_LOGIC;
  debug_pc: out STD_logic_vector(31 downto 0);
  debug_inst_invalid: out std_logic;

  to_physical_addr : out std_logic_vector(23 downto 0);
  to_physical_data : out std_logic_vector(31 downto 0);

  to_physical_read_enable : out std_logic;
  to_physical_write_enable : out std_logic;

  from_physical_data : in std_logic_vector(31 downto 0);
  from_physical_ready : in std_logic;
  from_physical_serial : in std_logic

  );
end component;

component mem_phy
port(
  clk : in  STD_LOGIC;
  addr : in  STD_LOGIC_VECTOR (23 downto 0);
  data_in : in  STD_LOGIC_VECTOR (31 downto 0);
  data_out : out  STD_LOGIC_VECTOR (31 downto 0) := X"FFFFFFFF";
  write_enable : in  STD_LOGIC;
  read_enable : in  STD_LOGIC;
  busy: out STD_LOGIC := '0';
  serialport_data_ready : out  STD_LOGIC;

  -- ports connected with ram
  baseram_addr: out std_logic_vector(19 downto 0);
  baseram_data: inout std_logic_vector(31 downto 0);
  baseram_ce: out std_logic;
  baseram_oe: out std_logic;
  baseram_we: out std_logic;
  extraram_addr: out std_logic_vector(19 downto 0);
  extraram_data: inout std_logic_vector(31 downto 0);
  extraram_ce: out std_logic;
  extraram_oe: out std_logic;
  extraram_we: out std_logic;

  -- ports connected with flash
  flash_addr : out  STD_LOGIC_VECTOR (22 downto 0);
  flash_data : inout  STD_LOGIC_VECTOR (15 downto 0);
  flash_control_ce0 : out  STD_LOGIC;
  flash_control_ce1 : out  STD_LOGIC;
  flash_control_ce2 : out  STD_LOGIC;
  flash_control_byte : out  STD_LOGIC;
  flash_control_vpen : out  STD_LOGIC;
  flash_control_rp : out  STD_LOGIC;
  flash_control_oe : out  STD_LOGIC;
  flash_control_we : out  STD_LOGIC;

  -- ports connected with serial port
  serialport_txd : out STD_LOGIC;
  serialport_rxd : in STD_LOGIC
  );
end component;

signal debug_inst_valid_backup: std_logic_vector(31 downto 0);
-- CPU -- mem_phy
signal physical_addr: STD_LOGIC_VECTOR(23 downto 0);
signal physical_data_in: STD_LOGIC_VECTOR(31 downto 0);
signal physical_data_out: STD_LOGIC_VECTOR(31 downto 0);
signal write_enable: STD_LOGIC;
signal read_enable: STD_LOGIC;
signal busy: STD_LOGIC;
signal ready_data: STD_LOGIC;
signal serialport_data_ready: STD_LOGIC;

signal debug_ce: STD_LOGIC;
signal debug_oe: STD_LOGIC;
signal debug_we: STD_LOGIC;

begin

cpu0: openmips port map(
  rst => rst, clk => clk, to_physical_addr => physical_addr, to_physical_data => physical_data_in,
  to_physical_read_enable => read_enable, to_physical_write_enable => write_enable,
  from_physical_data => physical_data_out, from_physical_ready => ready_data, from_physical_serial => serialport_data_ready, debug_pc => debug_pc, debug_inst_valid => debug_inst_valid_backup
  );

ready_data <= not busy;

mem_phy0: mem_phy port map(
  clk => clk, addr => physical_addr, data_in => physical_data_in, data_out => physical_data_out, write_enable => write_enable,
  read_enable => read_enable, busy => busy, serialport_data_ready => serialport_data_ready,
  baseram_we => debug_we, baseram_oe => debug_oe, baseram_ce => debug_ce, baseram_data => baseram_data, baseram_addr => baseram_addr,
  extraram_we => extraram_we, extraram_oe => extraram_oe, extraram_ce => extraram_ce, extraram_data => extraram_data, extraram_addr => extraram_addr,
  flash_data => flash_data, flash_addr => flash_addr, flash_control_ce0 => flash_control_ce0, flash_control_ce1 => flash_control_ce1, flash_control_ce2 => flash_control_ce2,
  flash_control_byte => flash_control_byte, flash_control_vpen => flash_control_vpen, flash_control_rp => flash_control_rp, flash_control_oe => flash_control_oe,
  flash_control_we => flash_control_we, serialport_txd => serialport_txd, serialport_rxd => serialport_rxd
  );

baseram_we <= debug_we;
baseram_ce <= debug_ce;
baseram_oe <= debug_oe;
process(debug_ce, debug_oe, debug_we, baseram_data)
begin
  if(debug_we = '0' and debug_oe = '1' and debug_ce = '0') then 
    debug_data <= baseram_data(15 downto 0);
  end if;
end process;

process(debug_inst_valid_backup, rst)
begin
  if(rst = '0') then
    debug_inst_invalid <= '0';
  elsif(debug_inst_valid_backup = '0') then
    debug_inst_invalid <= '1';
  end if;
end process;

end architecture ; -- arch
