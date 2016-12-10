LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY serialandflash is
  port(
    rst : in STD_LOGIC;
    clk : in STD_LOGIC;
    data_out : out std_logic_vector(15 downto 0);
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
    write_enable_flash : in std_logic;
    data_ready : out std_logic;

    RxD : in std_logic;
    write_enable_serial : in std_logic;
    int_ack : in std_logic;
    int_req : out std_logic;
    write_not_busy : out std_logic;
    RxD_data_ready_out : out std_logic
  );
end serialandflash;

architecture arch of serialandflash is

  component serial2flash
  port(
    clk : in  STD_LOGIC;
    rst : in STD_LOGIC;
    data_in : in STD_LOGIC_VECTOR (15 downto 0);
    data_out : out  STD_LOGIC_VECTOR (15 downto 0);
    write_enable: in std_logic;
    data_ready: out std_logic;
    flash_addr : out  STD_LOGIC_VECTOR (22 downto 0);
    flash_data : inout  STD_LOGIC_VECTOR (15 downto 0);
    flash_control_ce0 : out std_logic;
    flash_control_ce1 : out std_logic;
    flash_control_ce2 : out std_logic;
    flash_control_byte : out std_logic;
    flash_control_vpen : out std_logic;
    flash_control_rp : out std_logic;
    flash_control_oe : out std_logic;
    flash_control_we : out std_logic
  );
  end component;

  component serial_port
  port(
    clk : in std_logic;
    rst : in std_logic;
    int_ack : in std_logic;
    write_enable : in std_logic;
    RxD : in std_logic;
    int_req : out std_logic;
    data_out : out std_logic_vector(15 downto 0);
    write_not_busy : out std_logic;
    RxD_data_ready_out : out std_logic
  );
  end component;

  signal data_serial2flash : STD_LOGIC_VECTOR(15 downto 0);

  begin

  serial2flash0 : serial2flash port map(
    clk => clk,
    rst => rst,
    data_in => data_serial2flash,
    data_out => data_out,
    write_enable => write_enable_flash,
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
    flash_control_we => flash_control_we
  );

  serial_port0 : serial_port port map(
    clk => clk,
    rst => rst,
    int_ack => int_ack,
    int_req => int_req,
    data_out => data_serial2flash,
    write_enable => write_enable_serial,
    write_not_busy => write_not_busy,
    RxD_data_ready_out => RxD_data_ready_out,
    RxD => RxD
  );
