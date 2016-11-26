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

    extraram_addr: out std_logic_vector(19 downto 0);
    extraram_data: inout std_logic_vector(31 downto 0);
    extraram_ce: out std_logic;
    extraram_oe: out std_logic;
    extraram_we: out std_logic

    );
end DWPC;

architecture arch of DWPC is

component openmips
port(
  rst: in STD_LOGIC;
  clk: in STD_LOGIC;

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
  extrram_addr: out std_logic_vector(19 downto 0);
  extrram_data: inout std_logic_vector(31 downto 0);
  extrram_ce: out std_logic;
  extrram_oe: out std_logic;
  extrram_we: out std_logic;

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

component ram
Port(
  -- up
  clk: in std_logic;
  rst: in std_logic;
     
  ope_addr: in std_logic_vector(19 downto 0);
  write_data: in std_logic_vector(31 downto 0);
  read_data: out std_logic_vector(31 downto 0);
  ope_we: in std_logic;
  ope_ce1: in std_logic;
  ope_ce2: in std_logic;
       
  -- down
  baseram_addr: out std_logic_vector(19 downto 0);
  baseram_data: inout std_logic_vector(31 downto 0);
  baseram_ce: out std_logic;
  baseram_oe: out std_logic;
  baseram_we: out std_logic;

  extraram_addr: out std_logic_vector(19 downto 0);
  extraram_data: inout std_logic_vector(31 downto 0);
  extraram_ce: out std_logic;
  extraram_oe: out std_logic;
  extraram_we: out std_logic
);
end component;



begin


end architecture ; -- arch
