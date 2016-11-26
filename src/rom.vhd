library IEEE;
use IEEE.STD_LOGIC_1164.all;

package rom is

constant ROM_SIZE : integer := 84;
TYPE ROM is array(0 to ROM_SIZE - 1) of std_logic_vector(31 downto 0);

constant boot_rom : ROM := (
X"00000000",
X"10000001",
X"00000000",
X"3c10be00",
X"240f0000",
X"020f7821",
X"8de90000",
X"8def0004",
X"000f7c00",
X"012f4825",
X"3c08464c",
X"3508457f",
X"11090003",
X"00000000",
X"10000042",
X"00000000",
X"240f0038",
X"020f7821",
X"8df10000",
X"8def0004",
X"000f7c00",
X"022f8825",
X"240f0058",
X"020f7821",
X"8df20000",
X"8def0004",
X"000f7c00",
X"024f9025",
X"3252ffff",
X"240f0030",
X"020f7821",
X"8df30000",
X"8def0004",
X"000f7c00",
X"026f9825",
X"262f0008",
X"000f7840",
X"020f7821",
X"8df40000",
X"8def0004",
X"000f7c00",
X"028fa025",
X"262f0010",
X"000f7840",
X"020f7821",
X"8df50000",
X"8def0004",
X"000f7c00",
X"02afa825",
X"262f0004",
X"000f7840",
X"020f7821",
X"8df60000",
X"8def0004",
X"000f7c00",
X"02cfb025",
X"12800010",
X"00000000",
X"12a0000e",
X"00000000",
X"26cf0000",
X"000f7840",
X"020f7821",
X"8de80000",
X"8def0004",
X"000f7c00",
X"010f4025",
X"ae880000",
X"26d60004",
X"26940004",
X"26b5fffc",
X"1ea0fff4",
X"00000000",
X"26310020",
X"2652ffff",
X"1e40ffd7",
X"00000000",
X"02600008",
X"00000000",
X"1000ffff",
X"00000000",
X"1000ffff",
X"00000000",
X"00000000"
    ); 

end rom;


