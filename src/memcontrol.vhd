LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
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
    align_type: out std_logic_vector(1 downto 0)
    );

end memcontrol;

architecture arch of memcontrol is
signal state_SB : std_logic_vector(1 downto 0) := "00";
signal data_ready_SB := '1'
begin
  process(inst_ce_o, ram_ce_o, ram_data_o, ram_we_o, ram_align, read_data, inst_addr_o, ram_addr_o, data_ready)
  begin
    if(inst_ce_o = '1') then
      if(ram_ce_o = '1') then
        if(ram_we_o /= '1' or ram_align /= ALIGN_TYPE_BYTE) then 
          stallreq <= '1';
          ope_ce <= '1';
          ope_addr <= ram_addr_o;
          ope_we <= ram_we_o;
          align_type <= ram_align;
          ram_data_i <= read_data;
          write_data <= ram_data_o;
          inst_data_i <= (others => '0');
        else 
          case state_SB is 
          when "00" => 
            state_SB <= "01";
            data_ready_SB <= '0';
            ope_ce <= '1';
            ope_addr <= ram_addr_o;
            ope_we <= '0';
            align_type <= ram_align;
          when "01" =>
            if(data_ready = '1' and read_data /= (others => 'Z')) then
              state_SB <= "11";
              ope_we <= '1';
              case ram_addr_o(1 downto 0) is
              when "00" => write_data <= read_data(31 downto 8) & ram_data_o(7 downto 0);
              when "01" => write_data <= read_data(31 downto 16) & ram_data_o(15 downto 8) & read_data(7 downto 0);
              when "10" => write_data <= read_data(31 downto 24) & ram_data_o(23 downto 16) & read_data(15 downto 0);
              when "11" => write_data <= ram_data_o(31 downto 24) & ram_data_o(23 downto 0);
              when others => write_data <= read_data;
              end case;
              data_ready_SB <= '1';
              stallreq <= '1';
            end if;
          when "11" => 
            state_SB <= "00";
          end case;
        end if;
      else
        stallreq <= '0';
        ope_ce <= '1';
        ope_we <= '0';
        ope_addr <= inst_addr_o;
        align_type <= ALIGN_TYPE_WORD;
        write_data <= (others => '0');
        inst_data_i <= read_data;
        ram_data_i <= (others => '0');
      end if;
    else
      ope_ce <= '0';
      ope_we <= '0';
      ope_addr <= (others => '0');
      write_data <= (others => '0');
      align_type <= ALIGN_TYPE_WORD;
      stallreq <= '0';
      ram_data_i <= (others => '0');
      inst_data_i <= (others => '0');
    end if;
  end process;

  stallreq_all <= not (data_ready and data_ready_SB);

  --process(clk, ram_ce_o, ram_data_o, ram_we_o, ram_align, read_data, inst_addr_o, ram_addr_o)
  --begin
  --  if(clk'event and clk = '1') then 
  --    case state_SB is
  --    when 0 => 
  --      if(ram_ce_o = '1' and ram_we_o = '1' and ram_align = ALIGN_TYPE_BYTE) then
  --        state_SB <= 1;
  --        data_ready_SB <= '0';
  --        ope_ce <= '1';
  --        ope_addr <= ram_addr_o;
  --        ope_we <= '0';
  --        align_type <= ram_align;
  --        ram_data_i <= read_data;
  --        write_data <= ram_data_o;  
  --    end if;
  --    end case;
  --  end if;
  --end process;



end architecture ; -- arch
