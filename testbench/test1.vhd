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
 
ENTITY test1 IS
END test1;
 
ARCHITECTURE behavior OF test1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DWPC
    PORT(
      rst : IN  std_logic;
      clk : IN  std_logic;
      baseram_addr : OUT  std_logic_vector(19 downto 0);
      baseram_data : INOUT  std_logic_vector(31 downto 0);
      baseram_ce : OUT  std_logic;
      baseram_oe : OUT  std_logic;
      baseram_we : OUT  std_logic;
      extraram_addr : OUT  std_logic_vector(19 downto 0);
      extraram_data : INOUT  std_logic_vector(31 downto 0);
      extraram_ce : OUT  std_logic;
      extraram_oe : OUT  std_logic;
      extraram_we : OUT  std_logic;
      flash_addr : OUT  std_logic_vector(22 downto 0);
      flash_data : INOUT  std_logic_vector(15 downto 0);
      flash_control_ce0 : OUT  std_logic;
      flash_control_ce1 : OUT  std_logic;
      flash_control_ce2 : OUT  std_logic;
      flash_control_byte : OUT  std_logic;
      flash_control_vpen : OUT  std_logic;
      flash_control_rp : OUT  std_logic;
      flash_control_oe : OUT  std_logic;
      flash_control_we : OUT  std_logic;
      serialport_txd : OUT  std_logic;
      serialport_rxd : IN  std_logic
    );
    END COMPONENT;

    COMPONENT ram_simulate
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
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal serialport_rxd : std_logic := '0';

  --BiDirs
   signal baseram_data : std_logic_vector(31 downto 0);
   signal extraram_data : std_logic_vector(31 downto 0);
   signal flash_data : std_logic_vector(15 downto 0);

  --Outputs
   signal baseram_addr : std_logic_vector(19 downto 0);
   signal baseram_ce : std_logic;
   signal baseram_oe : std_logic;
   signal baseram_we : std_logic;
   signal extraram_addr : std_logic_vector(19 downto 0);
   signal extraram_ce : std_logic;
   signal extraram_oe : std_logic;
   signal extraram_we : std_logic;
   signal flash_addr : std_logic_vector(22 downto 0);
   signal flash_control_ce0 : std_logic;
   signal flash_control_ce1 : std_logic;
   signal flash_control_ce2 : std_logic;
   signal flash_control_byte : std_logic;
   signal flash_control_vpen : std_logic;
   signal flash_control_rp : std_logic;
   signal flash_control_oe : std_logic;
   signal flash_control_we : std_logic;
   signal serialport_txd : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
   constant DELAY: time := 10 ns;

   signal init: std_logic := '0';



BEGIN
process
    file in_file: text open read_mode is "inst.txt";
    variable line_str: line;
    variable address: std_logic_vector(31 downto 0);
    variable data: std_logic_vector(31 downto 0);
begin
    -- Initialize memory by reading file
    
    while not endfile(in_file) loop
        rst <= '0';
        readline(in_file, line_str);
        --report line_str;
        hread(line_str, address);
        hread(line_str, data);
        if address(22) = '0' then
          baseram_addr <= address(21 downto 2);
          baseram_oe <= '1';
          baseram_ce <= '0';
          baseram_we <= '0';
          baseram_data <= data;
        else
          extraram_addr <= address(21 downto 2);
          extraram_oe <= '1';
          extraram_ce <= '0';
          extraram_we <= '0';
          extraram_data <= data;
        end if;
        wait for 30 ns;
    end loop;
    rst <= '1';
end process ; 


  -- Instantiate the Unit Under Test (UUT)
   uut: DWPC PORT MAP (
          rst => rst,
          clk => clk,
          baseram_addr => baseram_addr,
          baseram_data => baseram_data,
          baseram_ce => baseram_ce,
          baseram_oe => baseram_oe,
          baseram_we => baseram_we,
          extraram_addr => extraram_addr,
          extraram_data => extraram_data,
          extraram_ce => extraram_ce,
          extraram_oe => extraram_oe,
          extraram_we => extraram_we,
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
          serialport_txd => serialport_txd,
          serialport_rxd => serialport_rxd
        );


   ram_simulate0: ram_simulate PORT MAP (
          baseram_addr => baseram_addr, 
          baseram_data => baseram_data, 
          baseram_ce => baseram_ce, 
          baseram_we => baseram_we,
          baseram_oe => baseram_oe, 
          extraram_addr => extraram_addr, 
          extraram_data => extraram_data, 
          extraram_ce => extraram_ce, 
          extraram_we => extraram_we, 
          extraram_oe => extraram_oe
    );

   -- Clock process definitions
   clk_process :process
   begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin    
      -- hold reset state for 100 ns.
      wait for 100 ns;  

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
