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
begin

  memcontrol : process(clk, rst)
  variable state : integer := 0;
  begin
    if(rst = '0') then
      ope_ce <= '0';
      ope_we <= '0';
      ope_addr <= (others => '0');
      write_data <= (others => '0');
      align_type <= ALIGN_TYPE_WORD;
      stallreq <= '0';
      state := 0;
    elsif (clk'event and clk = '1') then
      case state is
        when 0 =>
          if(inst_ce_o = '1') then
            ope_ce <= '1';
            ope_we <= '0';
            ope_addr <= inst_addr_o;
            align_type <= ALIGN_TYPE_WORD;
            write_data <= (others => '0');
            stallreq <= '1';
            state := 1;
          elsif (ram_ce_o = '1') then
            stallreq <= '1';
            state := 3;
            ope_ce <= '1';
            ope_addr <= ram_data_o;
            ope_we <= ram_we_o;
            align_type <= ram_align;
            write_data <= ram_data_o;
          end if;
        when 1 =>
          ope_ce <= '0';
          stallreq <= '1';
          state := 2;
        when 2 =>
          if(data_ready = '1') then
            inst_data_i <= read_data;
            if(ram_ce_o = '0') then
              ope_ce <= '0';
              ope_we <= '0';
              ope_addr <= (others => '0');
              write_data <= (others => '0');
              align_type <= ALIGN_TYPE_WORD;
              stallreq <= '0';
              state := 0;
            else
              stallreq <= '1';
              state := 3;
              ope_ce <= '1';
              ope_addr <= ram_data_o;
              ope_we <= ram_we_o;
              align_type <= ram_align;
              write_data <= ram_data_o;
            end if;
          end if;
        when 3 =>
          ope_ce <= '0';
          stallreq <= '1';
          state := 4;
        when 4 =>
          if(data_ready = '1') then
            ram_data_i <= read_data;
            ope_ce <= '0';
            ope_we <= '0';
            ope_addr <= (others => '0');
            write_data <= (others => '0');
            align_type <= ALIGN_TYPE_WORD;
            stallreq <= '0';
            state := 0;
          end if;
        when others => 
          ope_ce <= '0';
          ope_we <= '0';
          ope_addr <= (others => '0');
          write_data <= (others => '0');
          align_type <= ALIGN_TYPE_WORD;
          stallreq <= '0';
          state := 0;
      end case;
    end if;
  end process;

end architecture ; -- arch
