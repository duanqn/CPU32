LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.CPU32.all;

entity mmu is
  port (
    --up
    ope_addr: in std_logic_vector(31 downto 0);
    ope_data: in std_logic_vector(31 downto 0);
    result_data: out std_logic_vector(31 downto 0);
    ope_we: in std_logic;
    ope_ce: in std_logic;

    --down
    phy_addr: out std_logic_vector(31 downto 0);
    phy_data: out std_logic_vector(31 downto 0);
    storage_data: in std_logic_vector(31 downto 0);
    phy_we: out std_logic;
    phy_ce: out std_logic

  ) ;
end entity ; --mmu


architecture arch of mmu is

begin
identifier : process(ope_addr, ope_data, ope_we, ope_ce, storage_data)
begin
  result_data <= storage_data;
  phy_ce <= ope_ce;
  phy_we <= ope_we;
  phy_data <= ope_data;
  phy_addr <= ope_addr(22 downto 2);
end process ; -- identifier

end architecture ; -- arch