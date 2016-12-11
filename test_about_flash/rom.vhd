library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.CPU32.all;


package rom is

constant ROM_SIZE : integer := 32;
TYPE ROM is array(0 to ROM_SIZE - 1) of std_logic_vector(31 downto 0);

constant boot_rom : ROM := (
x"3C049E00",
x"3C020000",
x"34420080",
x"3C058000",
x"00631826",
x"00834021",
x"95010000",
x"95070002",
x"00073C00",
x"00270825",
x"00A34021",
x"AD010000",
x"24630004",
x"00433023",
x"1CC0FFF6",
x"00000000",
x"00A00008",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000",
x"00000000"
    );

end rom;
