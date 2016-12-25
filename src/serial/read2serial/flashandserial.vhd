LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY flashandserial is
  port(
    rst : in STD_LOGIC;
    clk : in STD_LOGIC;
    flash_addr : out std_logic_vector(22 downto 0);
    flash_data : inout std_logic_vector(15 downto 0);
    flash_control_ce0 : out std_logic;
    flash_control_ce1 : out std_logic;
    flash_control_ce2 : out std_logic;
    flash_control_byte : out std_logic;
    flash_control_vpen : out std_logic;
    flash_control_rp : out std_logic;
    flash_control_oe : out std_logic;
    flash_control_we : out std_logic;
    TxD : out std_logic
  );
end flashandserial;

architecture arch of flashandserial is

  component flash2serial
  port(
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    data_out : out  STD_LOGIC_VECTOR (15 downto 0);
    read_enable: in std_logic;
    data_ready: out std_logic;
    flash_addr : out  STD_LOGIC_VECTOR (22 downto 0);
    flash_data : inout  STD_LOGIC_VECTOR (15 downto 0);
    flash_control_ce0: out std_logic;
    flash_control_ce1: out std_logic;
    flash_control_ce2: out std_logic;
    flash_control_byte: out std_logic;
    flash_control_vpen: out std_logic;
    flash_control_rp: out std_logic;
    flash_control_oe: out std_logic;
    flash_control_we: out std_logic
  );
  end component;

  component serial_port
  port(
    clk : in std_logic;
    rst : in std_logic;
    data_in : in std_logic_vector(15 downto 0);
    write_enable : in std_logic;
    write_not_busy : out std_logic;
    TxD : out std_logic
  );
end component;

signal data_flash2serial : STD_LOGIC_VECTOR(15 downto 0);
signal data_ready : STD_LOGIC;
signal write_not_busy : STD_LOGIC;

begin

  flash2serial0 : flash2serial port map(
    clk => clk,
    rst => rst,
    data_out => data_flash2serial,
    data_ready => data_ready,
    flash_addr => flash_addr,
    flash_data => flash_data,
    flash_control_ce0 => flash_control_ce0,
    flash_control_ce1 => flash_control_ce1,
    flash_control_ce2 => flash_control_ce2,
    flash_control_byte => flash_control_byte,
    flash_control_vpen => flash_control_vpen,
    flash_control_rp => flash_control_rp,
    flash_control_oe => flash_control_oe,
    flash_control_we => flash_control_we,

    read_enable => write_not_busy
  );

  serial_port0 : serial_port port map(
    clk => clk,
    rst => rst,
    data_in => data_flash2serial,
    TxD => TxD,
    write_enable => data_ready,
    write_not_busy => write_not_busy
  );
end architecture;
