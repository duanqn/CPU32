LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.CPU32.all;

ENTITY memcontrol is
  port(

    --up
    rst: in STD_LOGIC;
    clk: in STD_LOGIC;
    inst_data_i: out STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    inst_addr_o: in STD_LOGIC_VECTOR(31 downto 0);
    inst_ce_o: in STD_LOGIC;

    mem_data_i: out STD_LOGIC_VECTOR(31 downto 0);
    mem_addr_o: in STD_LOGIC_VECTOR(31 downto 0);
    mem_data_o: in STD_LOGIC_VECTOR(31 downto 0);
    mem_we_o: in STD_LOGIC;
    mem_align: in STD_LOGIC_VECTOR(1 downto 0);
    mem_ce_o: in STD_LOGIC;

    --mix
    stallreq: out STD_LOGIC;
    stallreq_all: out STD_LOGIC;

    --down
    ope_addr: out std_logic_vector(31 downto 0);
    write_data: out std_logic_vector(31 downto 0);
    ope_we: out std_logic;
    ope_ce: out std_logic;
    align_type: out std_logic_vector(1 downto 0);
    signal_sb: out std_logic;

    read_data: in std_logic_vector(31 downto 0);
    data_ready: in std_logic;
    exc_signal : in std_logic
    );

end memcontrol;

architecture arch of memcontrol is
signal state : std_logic_vector(3 downto 0) := "0000";
signal state_backup : std_logic_vector(3 downto 0) := "0000";
signal read_data_sb : std_logic_vector(31 downto 0) := (others => '0');
signal position_sb: std_logic_vector(1 downto 0) := (others => '0');


begin

  process(clk)
  begin
    if(clk'event and clk = '1') then 
      case state is 
      when "0000" => 
        if(mem_ce_o = '1') then
          if(mem_we_o = '1' and mem_align = ALIGN_TYPE_BYTE and mem_addr_o /= VIRTUAL_SERIAL_DATA and mem_addr_o /= VIRTUAL_SERIAL_STATUS) then 
            -- sb
            stallreq <= '1';
            state <= "0110";
            ope_ce <= '1';
            ope_we <= '0';
            ope_addr <= mem_addr_o;
            align_type <= mem_align;
            write_data <= (others => '0');
            signal_sb <= '1';
            position_sb <= mem_addr_o(1 downto 0);
          else
            -- mem
            stallreq <= '1';
            state <= "0100";
            ope_ce <= '1';
            ope_we <= mem_we_o;
            ope_addr <= mem_addr_o;
            align_type <= mem_align;
            write_data <= mem_data_o;
            signal_sb <= '0';
          end if;
        elsif (inst_ce_o = '1') then
          stallreq <= '0';
          state <= "0001";
          ope_ce <= '1';
          ope_we <= '0';
          ope_addr <= inst_addr_o;
          align_type <= ALIGN_TYPE_WORD;
          write_data <= (others => '0');
          signal_sb <= '0';
        else
          stallreq <= '0';
          state <= "0000";
          ope_ce <= '0';
          ope_we <= '0';
          ope_addr <= (others => '0');
          align_type <= ALIGN_TYPE_WORD;
          write_data <= (others => '0');
          signal_sb <= '0';
          inst_data_i <= (others => '0');
          mem_data_i <= (others => '0');
        end if;

      -- inst 1
      when "0001" => 
        if exc_signal = '1' then
          stallreq <= '0';
          state <= "0000";
        else
          state <= "0010";
        end if;

      -- inst 2
      when "0010" =>
        if(data_ready = '1') then
          stallreq_all <= '0';
          inst_data_i <= read_data;
          ope_ce <= '0';
          ope_we <= '0';
          state <= "0011";
        else 
          state_backup <= state;
          state <= "1100";
          stallreq_all <= '1';
        end if;

      -- normal mem 1
      when "0100" => 
        if exc_signal = '1' then
          stallreq <= '0';
          state <= "0000";
        else
          state <= "0101";
        end if;

      -- normal mem 2
      when "0101" => 
        if(data_ready = '1') then
          stallreq_all <= '0';
          mem_data_i <= read_data;
          ope_ce <= '0';
          ope_we <= '0';
          state <= "0011";
        else 
          state_backup <= state;
          state <= "1100";
          stallreq_all <= '1';
        end if;

      -- sb 1
      when "0110" => 
        if exc_signal = '1' then
          stallreq <= '0';
          state <= "0000";
        else
          state <= "0111";
        end if;

      -- sb 2
      when "0111" =>
        if(data_ready = '1') then
          stallreq_all <= '0';
          read_data_sb <= read_data;
          ope_ce <= '0';
          ope_we <= '0';
          state <= "1000";
        else 
          state_backup <= state;
          state <= "1100";
          stallreq_all <= '1';
        end if;

      -- sb 3
      when "1000" =>
        state <= "1001";

      -- sb 4
      when "1001" =>
        state <= "1010";
        ope_ce <= '1';
        ope_we <= '1';
        case position_sb(1 downto 0) is
          when "00" => write_data <= read_data_sb(31 downto 8) & mem_data_o(7 downto 0);
          when "01" => write_data <= read_data_sb(31 downto 16) & mem_data_o(15 downto 8) & read_data_sb(7 downto 0);
          when "10" => write_data <= read_data_sb(31 downto 24) & mem_data_o(23 downto 16) & read_data_sb(15 downto 0);
          when "11" => write_data <= mem_data_o(31 downto 24) & read_data_sb(23 downto 0);
          when others => write_data <= read_data_sb;
        end case;

      -- sb 5
      when "1010" =>
        state <= "1011";

      -- sb 6
      when "1011" =>
        if(data_ready = '1') then
          stallreq_all <= '0';
          ope_ce <= '0';
          ope_we <= '0';
          state <= "0011";
        else 
          state_backup <= state;
          state <= "1100";
          stallreq_all <= '1';
        end if;

      -- inst 3/mem 3/sb 7
      when "0011" => 
        state <= "0000";


      -- wait 1
      when "1100" =>
        state <= "1101";

      -- wait 2
      when "1101" => 
        state <= "1110";

      -- wait 3
      when "1110" =>
        state <= state_backup;

      when others => 
        state <= "0000";

      end case;
    end if;
  end process;

end architecture ; -- arch
