library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


    
entity ram is
    Port(clk: in std_logic;
         rst: in std_logic;
         
         ope_addr: in std_logic_vector(19 downto 0);
         write_data: in std_logic_vector(31 downto 0);
         read_data: out std_logic_vector(31 downto 0);
         ope_we: in std_logic;
         ope_ce: in std_logic;
           
         ram_addr: out std_logic_vector(19 downto 0);
         ram_data: inout std_logic_vector(31 downto 0);
         ram_ce: out std_logic;
         ram_oe: out std_logic;
         ram_we: out std_logic;
         
    );
end ram;

architecture Behavioral of ram is
    signal state: std_logic_vector(4 downto 0);
    -- fsm: read ram 1: 00000 -> 00001 -> 00000
    --     write ram 1: 00000 -> 10000 -> 00000
begin
    process(clk, rst)
    begin
        if (rst = '0') then
            read_data <= (others => '0');
            ram_addr <= (others => '0');
            state <= (others => '0');
            ram_data <= (others => 'Z');
            ram_ce <= '1';
            ram_oe <= '1';
            ram_we <= '1';
        elsif (clk'event and clk = '1') then
            case state is
                when "00000" => ram_data <= (others => 'Z');
                                if (ope_we = '1' and ope_ce = '1') then
                                    -- read  ram(ram1)
                                    ram_ce <= '0';
                                    ram_oe <= '0';
                                    ram_addr <= ope_addr;
                                    state <= "00001";
                                elsif (ope_we = '0' and ope_ce = '1') then
                                    -- write  ram(ram1)
                                    ram_oe <= '1';
                                    ram_ce <= '0';
                                    ram_we <= '0';
                                    ram_addr <= ope_addr;
                                    ram_data <= write_data;
                                    state <= "10000";
                                else
                                    state <= "00000";
                                end if;
                -- read ram 1
                when "00001" => read_data <= ram_data;
                                ram_ce <= '1';
                                ram_oe <= '1';
                                state <= "00000";

                -- write ram 1, stage 1, select ram, set write address and data
                when "10000" => ram_we <= '1';
                                ram_ce <= '1';
                                state <= "00000";

                when others =>  state <= (others => '0');
                                ram_data <= (others => 'Z');
                                ram_ce <= '1';
                                ram_oe <= '1';
                                ram_we <= '1';
            end case;
        end if;
    end process;

end Behavioral;
