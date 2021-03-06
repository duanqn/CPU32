--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   00:24:19 12/03/2016
-- Design Name:
-- Module Name:   D:/CPU/DWP/test1.vhd
-- Project Name:  DWP
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: DWPC
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_TEXTIO.all;
USE STD.TextIO.All;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY ram_simulate IS
  Port(
    baseram_addr : IN  std_logic_vector(19 downto 0);
    baseram_data : INOUT std_logic_vector(31 downto 0);
    baseram_ce : IN  std_logic;
    baseram_oe : IN  std_logic;
    baseram_we : IN  std_logic;
    extraram_addr : IN  std_logic_vector(19 downto 0);
    extraram_data : INOUT  std_logic_vector(31 downto 0);
    extraram_ce : IN  std_logic;
    extraram_oe : IN  std_logic;
    extraram_we : IN  std_logic
    );

END ram_simulate;

ARCHITECTURE behavior OF ram_simulate IS

type mem_array is array(262143 downto 0) of std_logic_vector(31 downto 0);
signal baseram: mem_array := (others => (others => '0'));
signal extraram: mem_array := (others => (others => '0'));

constant DELAY: time := 10 ns;

BEGIN
process(baseram_we, baseram_data, baseram_addr, baseram_oe, baseram_ce)
begin
    -- Write to baseMemory
    if(baseram_ce = '0' and baseram_oe = '0' and baseram_we = '1') then
      baseram_data <= transport baseram(to_integer(unsigned(baseram_addr(17 downto 0)))) after DELAY;
    elsif (baseram_ce = '0' and baseram_oe = '1' and baseram_we = '0') then
        baseram(to_integer(unsigned(baseram_addr(17 downto 0)))) <= baseram_data;
        --report "write base " & integer'image(to_integer(unsigned(baseram_addr(17 downto 0)))) & " to " & integer'image(to_integer(unsigned(baseram_data)));
    else
      baseram_data <= (others => 'Z');
    end if;
end process ;

process(extraram_we, extraram_data, extraram_addr, extraram_oe, extraram_ce)
begin
    -- Write to baseMemory
    if(extraram_ce = '0' and extraram_oe = '0' and extraram_we = '1') then
      extraram_data <= transport extraram(to_integer(unsigned(extraram_addr(17 downto 0)))) after DELAY;
    elsif (extraram_ce = '0' and extraram_oe = '1' and extraram_we = '0') then
        extraram(to_integer(unsigned(extraram_addr(17 downto 0)))) <= extraram_data;
        --report "write base " & integer'image(to_integer(unsigned(extraram_addr(17 downto 0)))) & " to " & integer'image(to_integer(unsigned(extraram_data)));
    else
      extraram_data <= (others => 'Z');
    end if;
end process ;

END;
