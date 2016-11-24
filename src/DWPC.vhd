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

  phy_addr: out std_logic_vector(31 downto 0);
  phy_data: out std_logic_vector(31 downto 0);
  storage_data: in std_logic_vector(31 downto 0);
  phy_we: out std_logic;
  phy_ce: out std_logic

  );
end component;

component ram
Port(

  -- up
  clk: in std_logic;
  rst: in std_logic;
     
  ope_addr_raw: in std_logic_vector(20 downto 0);
  write_data: in std_logic_vector(31 downto 0);
  read_data: out std_logic_vector(31 downto 0);
  ope_we: in std_logic;
  ope_ce: in std_logic;
       
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
  

signal phy_addr: STD_LOGIC_VECTOR(31 downto 0);
signal phy_data: STD_LOGIC_VECTOR(31 downto 0);
signal phy_we: STD_LOGIC;
signal phy_ce: STD_LOGIC;
signal storage_data: STD_LOGIC_VECTOR(31 downto 0);

begin

cpu: openmips port map(
  rst => rst, clk => clk, phy_addr => phy_addr, phy_data => phy_data, phy_we => phy_we, phy_ce => phy_ce, storage_data => storage_data
  );

ram0: ram port map(
  rst => rst, clk => clk, ope_addr_raw => phy_addr, ope_ce => phy_ce, ope_we => phy_we, write_data => phy_data, read_data => storage_data,
  baseram_we => baseram_we, baseram_oe => baseram_oe, baseram_ce => baseram_ce, baseram_data => baseram_data, baseram_addr => baseram_addr,
  extraram_data => extraram_data, extraram_we => extraram_we, extraram_oe => extraram_oe, extraram_ce => extraram_ce, extraram_addr => extraram_addr
  );

end architecture ; -- arch
