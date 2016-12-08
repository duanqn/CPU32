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
      baseram_data: INOUT  std_logic_vector(31 downto 0);  
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

    COMPONENT flash_simulate
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
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal serialport_rxd : std_logic := '0';

  --BiDirs
   signal baseram_data : std_logic_vector(31 downto 0);
   signal extraram_data : std_logic_vector(31 downto 0);
   --signal baseram_data_out : std_logic_vector(31 downto 0);
   --signal extraram_data_out : std_logic_vector(31 downto 0);
   --signal baseram_data_backup : std_logic_vector(31 downto 0);
   --signal extraram_data_backup : std_logic_vector(31 downto 0);
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

   flash_simulate0: flash_simulate PORT map (
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


  --process(baseram_data_backup, baseram_ce, baseram_we, baseram_oe)
  --begin
  --  if(baseram_ce = '0' and baseram_oe = '1' and baseram_we = '0') then
  --    baseram_data_in <= baseram_data_backup;
  --  end if;
  --end process;

  --process(baseram_data_out, baseram_ce, baseram_we, baseram_oe)
  --begin
  --  if(baseram_ce = '0' and baseram_oe = '0' and baseram_we = '1') then
  --    baseram_data_backup <= baseram_data_out;
  --  else 
  --    baseram_data_backup <= (others => 'Z');
  --  end if;
  --end process;

  --baseram_data_backup <= baseram_data_out;
   --baseram_data_in <= baseram_data_backup when baseram_ce = '0' and baseram_we = '0' and baseram_oe = '1' else (others => 'Z');
   --extraram_data_in <= extraram_data_backup when extraram_ce = '0' and extraram_we = '0' and extraram_oe = '1' else (others => 'Z');
   --baseram_data_backup <= baseram_data_out when baseram_ce = '0' and baseram_we = '1' and baseram_oe = '0' else (others => 'Z');
   --extraram_data_backup <= extraram_data_out when extraram_ce = '0' and extraram_we = '1' and extraram_oe = '0' else (others => 'Z');
   
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
      -- hold reset state for 40 ns.
      rst <= '0';
      wait for 40 ns;
      rst <= '1';

      -- insert stimulus here 

      wait;
   end process;

END;
