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
    baseram_data : INOUT  std_logic_vector(31 downto 0);
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

type mem_array is array(1023 downto 0) of std_logic_vector(31 downto 0);
signal memory: mem_array;

constant DELAY: time := 10 ns;

BEGIN
   baseram_data <= transport memory(to_integer(unsigned(baseram_addr(9 downto 0)))) after DELAY when baseram_ce = '0' and baseram_oe = '0' else (others => 'Z');
   extraram_data <= transport memory(to_integer(unsigned('1' & extraram_addr))) after DELAY when extraram_ce = '0' and extraram_oe = '0' else (others => 'Z');
process
begin
    -- Write to baseMemory
    Write_loop : loop 
        wait until falling_edge(baseram_we);
        memory(to_integer(unsigned(baseram_addr(9 downto 0))) <= transport baseram_data after DELAY;
        report "write base " & integer'image(to_integer(unsigned(baseram_addr(9 downto 0)))) & " to " & 
              integer'image(to_integer(unsigned(baseram_data)));
    end loop ;
end process ; 

process
begin
    -- Write to extraMemory
    Write_loop : loop 
        wait until falling_edge(extraram_we);
        memory(to_integer(unsigned('1' & extraram_addr))) <= transport extraram_data after DELAY;
        report "write extra " & integer'image(to_integer(unsigned(extraram_addr))) & " to " & 
              integer'image(to_integer(unsigned(extraram_data)));
    end loop ;
end process ; 

END;
