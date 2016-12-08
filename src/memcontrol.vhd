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
--signal state : integer := 0;
begin
  process(inst_ce_o, ram_ce_o, ram_data_o, ram_we_o, ram_align, read_data, inst_addr_o, ram_addr_o)
  begin
    if(inst_ce_o = '1') then
      if(ram_ce_o = '1') then
        stallreq <= '1';
        ope_ce <= '1';
        ope_addr <= ram_addr_o;
        ope_we <= ram_we_o;
        align_type <= ram_align;
        write_data <= ram_data_o;
        ram_data_i <= read_data;
        inst_data_i <= (others => '0');
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

  stallreq_all <= not data_ready;


end architecture ; -- arch
