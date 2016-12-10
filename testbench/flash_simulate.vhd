LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_TEXTIO.all;
USE STD.TextIO.All;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY flash_simulate IS
  Port(
    flash_addr : in  STD_LOGIC_VECTOR (22 downto 0);
    flash_data : inout  STD_LOGIC_VECTOR (15 downto 0);
    flash_control_ce0 : in  STD_LOGIC;
    flash_control_ce1 : in  STD_LOGIC;
    flash_control_ce2 : in  STD_LOGIC;
    flash_control_byte : in  STD_LOGIC;
    flash_control_vpen : in  STD_LOGIC;
    flash_control_rp : in  STD_LOGIC;
    flash_control_oe : in  STD_LOGIC;
    flash_control_we : in  STD_LOGIC
    );

END flash_simulate;

ARCHITECTURE behavior OF flash_simulate IS

type flash_array is array(524287 downto 0) of bit_vector(15 downto 0);
signal flash_memory: flash_array := (others => (others => '0'));

constant DELAY: time := 10 ns;

BEGIN
process(flash_control_oe)
begin
    if(flash_control_oe = '0') then
      flash_data <= transport TO_STDLOGICVECTOR(flash_memory(to_integer(unsigned(flash_addr(18 downto 1))))) after DELAY;
    else
      flash_data <= (others => 'Z');
    end if;
end process ;

END;
