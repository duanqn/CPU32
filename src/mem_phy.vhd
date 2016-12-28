library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.CPU32.ALL;
use work.rom.ALL;

entity mem_phy is
    Port (
      clk : in  STD_LOGIC;
      addr : in  STD_LOGIC_VECTOR (24 downto 0);
      data_in : in  STD_LOGIC_VECTOR (31 downto 0);
      data_out : out  STD_LOGIC_VECTOR (31 downto 0) := X"FFFFFFFF";
      write_enable : in  STD_LOGIC;
      read_enable : in  STD_LOGIC;
      busy: out STD_LOGIC := '0';
      serialport_data_ready : out  STD_LOGIC;

      -- ports connected with ram
      baseram_addr: out std_logic_vector(19 downto 0);
      baseram_data: inout std_logic_vector(31 downto 0);
      baseram_ce: out std_logic;
      baseram_oe: out std_logic;
      baseram_we: out std_logic;
      extraram_addr: out std_logic_vector(19 downto 0);
      extraram_data: inout std_logic_vector(31 downto 0);
      extraram_ce: out std_logic;
      extraram_oe: out std_logic;
      extraram_we: out std_logic;

      -- ports connected with flash
      flash_addr : out  STD_LOGIC_VECTOR (22 downto 0);
      flash_data : inout  STD_LOGIC_VECTOR (15 downto 0);
      flash_control_ce0 : out  STD_LOGIC;
      flash_control_ce1 : out  STD_LOGIC;
      flash_control_ce2 : out  STD_LOGIC;
      flash_control_byte : out  STD_LOGIC;
      flash_control_vpen : out  STD_LOGIC;
      flash_control_rp : out  STD_LOGIC;
      flash_control_oe : out  STD_LOGIC;
      flash_control_we : out  STD_LOGIC;

      -- ports connected with serial port
      serialport_txd : out STD_LOGIC;
      serialport_rxd : in STD_LOGIC
      );
end mem_phy;

architecture behave of mem_phy is

signal data_ready: STD_LOGIC := '1';
component ram
    Port(
      -- up
      clk: in std_logic;
      rst: in std_logic;

      ope_addr: in std_logic_vector(19 downto 0);
      write_data: in std_logic_vector(31 downto 0);
      read_data: out std_logic_vector(31 downto 0);
      ope_we: in std_logic;
      ope_ce1: in std_logic;
      ope_ce2: in std_logic;
      data_ready: out std_logic;

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
      extraram_we: out std_logic);
end component;

signal ram_ope_addr: std_logic_vector(19 downto 0);
signal ram_write_data: std_logic_vector(31 downto 0);
signal ram_read_data: std_logic_vector(31 downto 0);
signal ram_ope_we: std_logic;
signal ram_ope_ce1: std_logic := '0';
signal ram_ope_ce2: std_logic := '0';
signal ram_data_ready: std_logic;



component flash is
    Port (
      clk : in  STD_LOGIC;
      addr : in  STD_LOGIC_VECTOR (21 downto 0);
      data_in : in STD_LOGIC_VECTOR (15 downto 0);
      data_out : out  STD_LOGIC_VECTOR (15 downto 0);

      read_enable: in std_logic;
      write_enable: in std_logic;
      erase_enable: in std_logic;

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
      flash_control_we: out std_logic);
end component;

signal flash_read_signal: std_logic := '0';
signal flash_read_data: std_logic_vector(15 downto 0);
constant flash_write_data: std_logic_vector(15 downto 0) := (others => '0'); -- not supported
signal flash_ope_addr: std_logic_vector(21 downto 0);
signal flash_data_ready: std_logic;


component async_receiver
    port(
      clk: in std_logic;
      RxD: in std_logic;
      RxD_data_ready: out std_logic;
      RxD_data: out std_logic_vector(7 downto 0);
      RxD_idle: out std_logic;
      RxD_endofpacket: out STD_LOGIC
      );

end component;

signal serialport_receive_signal: std_logic := '0';
signal serialport_receive_data: std_logic_vector(7 downto 0);
signal serialport_data_latch: std_logic_vector(7 downto 0);
signal serialport_idle: STD_LOGIC;
signal serialport_endofpacket: STD_LOGIC;

component async_transmitter
    port(
      clk: in std_logic;
      TxD_start: in std_logic;
      TxD_data: in std_logic_vector(7 downto 0);
      TxD: out std_logic;
      TxD_busy: out std_logic);
end component;

signal serialport_transmit_signal : std_logic := '0';
signal serialport_transmit_data : std_logic_vector(7 downto 0);
signal serialport_transmit_busy : std_logic := '0';
signal serialport_state : STD_LOGIC_VECTOR(2 downto 0) := "000";
signal serialport_write_enable : STD_LOGIC := '0';


signal data_ready_part : STD_LOGIC := '0';
signal data_ready_serialport : STD_LOGIC := '0';




begin
    u3: async_receiver port map(
      clk => clk, RxD => serialport_rxd,
      RxD_data_ready => serialport_receive_signal,
      RxD_data => serialport_receive_data, RxD_idle => serialport_idle, RxD_endofpacket => serialport_endofpacket);

    u4: async_transmitter port map(
      clk => clk, Txd => serialport_txd,
      TxD_start => serialport_transmit_signal,TxD_data => serialport_transmit_data,
      Txd_busy => serialport_transmit_busy);

    u2: flash port map(
      clk => clk, addr => flash_ope_addr, data_in => flash_write_data,
      data_out => flash_read_data,flash_addr => flash_addr, flash_data => flash_data,
      read_enable => flash_read_signal, write_enable => '0', erase_enable => '0',
      flash_control_ce0 => flash_control_ce0, flash_control_ce1 => flash_control_ce1,
      flash_control_ce2 => flash_control_ce2, flash_control_byte => flash_control_byte,
      flash_control_vpen => flash_control_vpen, flash_control_rp => flash_control_rp,
      flash_control_oe => flash_control_oe, flash_control_we => flash_control_we, data_ready => flash_data_ready);

    u1: ram port map(
      clk => clk, rst => '1', ope_ce1 => ram_ope_ce1, ope_ce2 => ram_ope_ce2,
      ope_addr => ram_ope_addr, write_data => ram_write_data,
      read_data => ram_read_data, ope_we => ram_ope_we,
      baseram_addr => baseram_addr, baseram_data => baseram_data,
      baseram_ce => baseram_ce, baseram_oe => baseram_oe, baseram_we => baseram_we,
      extraram_addr => extraram_addr, extraram_data => extraram_data,
      extraram_ce => extraram_ce, extraram_oe => extraram_oe, extraram_we => extraram_we, data_ready => ram_data_ready);

    serialport_transmit_signal <= serialport_write_enable and (not serialport_transmit_busy);

    process(serialport_receive_signal, read_enable, addr, write_enable, serialport_receive_data, data_in, 
      flash_data_ready, ram_data_ready, serialport_transmit_busy, flash_read_data, ram_read_data)
    begin

      if (serialport_receive_signal = '1') then
        -- if have data incoming, latch it
        serialport_data_latch <= serialport_receive_data;
        serialport_data_ready <= '1';
      else
        serialport_data_latch <= (others => '0');
        serialport_data_ready <= '0';
      end if;

      -- read flash
      if (read_enable = '1' and addr(24 downto 22) = "100") then
        flash_ope_addr <= addr(21 downto 0);
        flash_read_signal <= '1';
        data_out <= flash_read_data & flash_read_data;        
        data_ready_part <= flash_data_ready;

        ram_ope_addr <= (others => '0');
        ram_write_data <= (others => '0');
        ram_ope_we <= '0';
        ram_ope_ce1 <= '0';
        ram_ope_ce2 <= '0';

        serialport_transmit_data <= (others => '0');

      -- write ram
      elsif (write_enable = '1' and addr(24 downto 22) = "001") then
        ram_ope_addr <= addr(19 downto 0);
        ram_write_data <= data_in;
        ram_ope_we <= '0';
        ram_ope_ce1 <= not addr(20);
        ram_ope_ce2 <= addr(20);
        data_ready_part <= ram_data_ready;

        serialport_transmit_data <= (others => '0');
        flash_read_signal <= '0';

      -- read ram
      elsif (read_enable = '1' and addr(24 downto 22) = "001") then
        ram_ope_addr <= addr(19 downto 0);
        ram_ope_we <= '1';
        ram_ope_ce1 <= not addr(20);
        ram_ope_ce2 <= addr(20);
        ram_write_data <= (others => '0');
        data_ready_part <= '1';
        data_out <= ram_read_data;

        serialport_transmit_data <= (others => '0');
        flash_read_signal <= '0';

      -- read serial port
      elsif (read_enable = '1' and addr(24 downto 22) = "010") then
        ram_ope_addr <= (others => '0');
        ram_write_data <= (others => '0');
        ram_ope_we <= '0';
        ram_ope_ce1 <= '0';
        ram_ope_ce2 <= '0';
        data_out <= X"000000" & serialport_data_latch;
        data_ready_part <= '1';

        serialport_transmit_data <= (others => '0');
        flash_read_signal <= '0';

      -- write serial port
      elsif (write_enable = '1' and addr(24 downto 22) = "010") then
          serialport_transmit_data <= data_in(7 downto 0);
          ram_ope_addr <= (others => '0');
          ram_write_data <= (others => '0');
          ram_ope_we <= '0';
          ram_ope_ce1 <= '0';
          ram_ope_ce2 <= '0';
          flash_read_signal <= '0';

      -- read rom
      elsif (read_enable = '1' and addr(24 downto 22) = "011") then
        data_out <= boot_rom(to_integer(unsigned(addr(4 downto 0))));
        data_ready_part <= '1';

        ram_ope_addr <= (others => '0');
        ram_write_data <= (others => '0');
        ram_ope_we <= '0';
        ram_ope_ce1 <= '0';
        ram_ope_ce2 <= '0';
        serialport_transmit_data <= (others => '0');
        flash_read_signal <= '0';

      else
        flash_read_signal <= '0';
        ram_ope_addr <= (others => '0');
        ram_write_data <= (others => '0');
        ram_ope_we <= '0';
        ram_ope_ce1 <= '0';
        ram_ope_ce2 <= '0';
        serialport_transmit_data <= (others => '0');
        flash_read_signal <= '0';
        data_out <= (others => '0');
        data_ready_part <= '1';
      end if;
    end process;

    process(clk)
    begin
      if (clk'event and clk = '1') then
        case serialport_state is
          when "000" =>
            if(addr(23 downto 22)) = "10" and write_enable = '1' then
              serialport_state <= "001";
              serialport_write_enable <= '1';
              data_ready_serialport <= '0';
            end if;
          when "001" =>
            serialport_state <= "011";
          when "011" =>
            serialport_write_enable <= '0';
            if serialport_transmit_busy = '0' then
              serialport_state <= "010";
              data_ready_serialport <= '1';
            end if;
          when "010" =>
            serialport_state <= "110";
          when "110" =>
            serialport_state <= "111";
          when "111" =>
            serialport_state <= "101";
          when "101" =>
            serialport_state <= "000";
          when others => null;
        end case;
      end if;
    end process;

    process(data_ready_serialport, addr, data_ready_part, write_enable)
    begin
      if(addr(23 downto 22) = "10" and write_enable = '1') then
        data_ready <= data_ready_serialport;
      else
        data_ready <= data_ready_part;
      end if;
    end process;

    busy <= not data_ready;

end behave;
