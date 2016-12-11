LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.CPU32.all;

ENTITY memcontrol is
  port(

    --up
    rst: in STD_LOGIC;
    clk: in STD_LOGIC;
    inst_data_i: out STD_LOGIC_VECTOR(31 downto 0);
    inst_addr_o: in STD_LOGIC_VECTOR(31 downto 0);
    inst_ce_o: in STD_LOGIC;

    ram_data_i: out STD_LOGIC_VECTOR(31 downto 0);
    ram_addr_o: in STD_LOGIC_VECTOR(31 downto 0);
    ram_data_o: in STD_LOGIC_VECTOR(31 downto 0);
    ram_we_o: in STD_LOGIC;
    ram_align: in STD_LOGIC_VECTOR(1 downto 0);
    ram_ce_o: in STD_LOGIC;

    --mix
    stallreq: out STD_LOGIC;
    stallreq_all: out STD_LOGIC;

    --down
    ope_addr: out std_logic_vector(31 downto 0);
    write_data: out std_logic_vector(31 downto 0);
    read_data: in std_logic_vector(31 downto 0);
    data_ready: in std_logic;
    ope_we: out std_logic;
    ope_ce: out std_logic;
    align_type: out std_logic_vector(1 downto 0);
    signal_sb: out std_logic
    );

end memcontrol;

architecture arch of memcontrol is
signal state_SB : std_logic_vector(2 downto 0) := "000";
signal data_ready_SB : std_logic := '1';
signal ope_ce_sb : std_logic := '0';
signal ope_ce_normal : std_logic := '0';
signal ope_we_sb : std_logic := '0';
signal ope_we_normal : std_logic := '0';
signal write_data_sb : std_logic_vector(31 downto 0) := (others => '0');
signal write_data_normal : std_logic_vector(31 downto 0) := (others => '0');
signal stallreq_sb : std_logic := '0';
signal stallreq_normal : std_logic := '0';


begin

  ope_ce <= ope_ce_normal or ope_ce_sb;
  ope_we <= ope_we_normal or ope_we_sb;

  about_sb: for i in 31 downto 0 generate
    write_data(i) <= write_data_normal(i) or write_data_sb(i);
  end generate about_sb;

  process(inst_ce_o, ram_ce_o, ram_data_o, ram_we_o, ram_align, read_data, inst_addr_o, ram_addr_o, data_ready)
  begin
    if(inst_ce_o = '1') then
      if(ram_ce_o = '1') then
        align_type <= ram_align;
        ope_addr <= ram_addr_o;
        if(ram_we_o = '1' and ram_align = ALIGN_TYPE_BYTE and ram_addr_o /= VIRTUAL_SERIAL_DATA and ram_addr_o /= VIRTUAL_SERIAL_STATUS) then 
          ope_ce_normal <= '0';
          ope_we_normal <= '0';
          write_data_normal <= (others => '0');
          signal_sb <= '1';
        else
          signal_sb <= '0';
          stallreq_normal <= '1';
          ope_ce_normal <= '1';
          ope_addr <= ram_addr_o;
          ope_we_normal <= ram_we_o;
          align_type <= ram_align;
          ram_data_i <= read_data;
          write_data_normal <= ram_data_o;
          inst_data_i <= (others => '0');
        end if;
      else
        signal_sb <= '0';
        stallreq_normal <= '0';
        ope_ce_normal <= '1';
        ope_we_normal <= '0';
        ope_addr <= inst_addr_o;
        align_type <= ALIGN_TYPE_WORD;
        write_data_normal <= (others => '0');
        inst_data_i <= read_data;
        ram_data_i <= (others => '0');
      end if;
    else
      signal_sb <= '0';
      ope_ce_normal <= '0';
      ope_we_normal <= '0';
      ope_addr <= (others => '0');
      write_data_normal <= (others => '0');
      align_type <= ALIGN_TYPE_WORD;
      stallreq_normal <= '0';
      ram_data_i <= (others => '0');
      inst_data_i <= (others => '0');
    end if;
  end process;

  stallreq_all <= not (data_ready and data_ready_SB);
  stallreq <= stallreq_sb or stallreq_normal;

  process(clk, ram_ce_o, ram_data_o, ram_we_o, ram_align, inst_addr_o, ram_addr_o)
  begin
    if(clk'event and clk = '1') then 
      case state_SB is
      when "000" => 
        if(ram_ce_o = '1' and ram_we_o = '1' and ram_align = ALIGN_TYPE_BYTE and ram_addr_o /= VIRTUAL_SERIAL_DATA and ram_addr_o /= VIRTUAL_SERIAL_STATUS) then
          state_SB <= "001";
          data_ready_SB <= '0';
        end if;
      when "001" => 
        state_SB <= "011";
        ope_ce_sb <= '1';
        ope_we_sb <= '0';
        write_data_sb <= (others => '0');
      when "011" => 
        state_SB <= "010";
      when "010" => 
        case ram_addr_o(1 downto 0) is
          when "00" => write_data_sb <= read_data(31 downto 8) & ram_data_o(7 downto 0);
          when "01" => write_data_sb <= read_data(31 downto 16) & ram_data_o(15 downto 8) & read_data(7 downto 0);
          when "10" => write_data_sb <= read_data(31 downto 24) & ram_data_o(23 downto 16) & read_data(15 downto 0);
          when "11" => write_data_sb <= ram_data_o(31 downto 24) & read_data(23 downto 0);
          when others => write_data_sb <= read_data;
        end case;
        state_SB <= "110";
        ope_ce_sb <= '1';
        ope_we_sb <= '1';
        data_ready_SB <= '1';
        stallreq_sb <= '1';
      when "110" => 
        state_SB <= "111";
        ope_ce_sb <= '0';
        ope_we_sb <= '0';
        write_data_sb <= (others => '0');
      when "111" => 
        state_SB <= "101";
      when "101" =>
        stallreq_sb <= '0';
        state_SB <= "000";
      when others => 
        state_SB <= "000";
      end case;
    end if;
  end process;
end architecture ; -- arch
