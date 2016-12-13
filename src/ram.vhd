library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.CPU32.all;


    
entity ram is
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
      extraram_we: out std_logic
    );
end ram;

architecture Behavioral of ram is
    signal state: std_logic_vector(4 downto 0);
    -- fsm: read ram 1: 00000 -> 00001 -> 00000
    --     write ram 1: 00000 -> 10000 -> 00000
    --     read ram 2: 00000 -> 00010 -> 00000
    --     write ram 2: 00000 -> 01000 -> 00000

begin
    process(clk, rst)
    begin
        if (rst = '0') then
            baseram_addr <= (others => '0');
            state <= (others => '0');
            baseram_data <= (others => 'Z');
            baseram_ce <= '1';
            baseram_oe <= '1';
            baseram_we <= '1';
            extraram_addr <= (others => '0');
            extraram_data <= (others => 'Z');
            extraram_ce <= '1';
            extraram_oe <= '1';
            extraram_we <= '1';
            data_ready <= '1';

        elsif (clk'event and clk = '1') then
            case state is
                when "00000" => baseram_data <= (others => 'Z');
                                extraram_data <= (others => 'Z');
                                if (ope_we = '1' and ope_ce1 = '1') then
                                    -- read  ram(ram1)
                                    baseram_ce <= '0';
                                    baseram_oe <= '0';
                                    baseram_we <= '1';
                                    extraram_ce <= '1';
                                    extraram_oe <= '1';
                                    extraram_we <= '1';
                                    baseram_addr <= ope_addr;
                                    data_ready <= '0';
                                    state <= "00001";

                                elsif (ope_we = '0' and ope_ce1 = '1') then
                                    -- write  ram(ram1)
                                    baseram_oe <= '1';
                                    baseram_ce <= '0';
                                    baseram_we <= '0';
                                    extraram_ce <= '1';
                                    extraram_oe <= '1';
                                    extraram_we <= '1';
                                    baseram_addr <= ope_addr;
                                    baseram_data <= write_data;
                                    data_ready <= '0';
                                    state <= "10000";
                                elsif (ope_we = '0' and ope_ce2 = '1') then
                                    -- write  ram(ram2)
                                    extraram_oe <= '1';
                                    extraram_ce <= '0';
                                    extraram_we <= '0';
                                    baseram_ce <= '1';
                                    baseram_oe <= '1';
                                    baseram_we <= '1';
                                    extraram_addr <= ope_addr;
                                    extraram_data <= write_data;
                                    data_ready <= '0';
                                    state <= "01000";
                                elsif (ope_we = '1' and ope_ce2 = '1') then
                                    -- read  ram(ram2)
                                    extraram_ce <= '0';
                                    extraram_oe <= '0';
                                    baseram_ce <= '1';
                                    baseram_oe <= '1';
                                    baseram_we <= '1';
                                    extraram_we <= '1';
                                    extraram_addr <= ope_addr;
                                    data_ready <= '0';
                                    state <= "00010";
                                else
                                    data_ready <= '1';
                                    state <= "00000";
                                end if;
                -- read ram 1
                when "00001" => 
                                baseram_ce <= '1';
                                baseram_oe <= '1';
                                data_ready <= '1';
                                state <= "00000";

                -- write ram 1
                when "10000" => baseram_we <= '1';
                                baseram_ce <= '1';
                                data_ready <= '1';
                                state <= "00000";

                -- read ram 2
                when "00010" => 
                                extraram_ce <= '1';
                                extraram_oe <= '1';
                                data_ready <= '1';
                                state <= "00000";

                -- write ram 2
                when "01000" => extraram_we <= '1';
                                extraram_ce <= '1';
                                data_ready <= '1';
                                state <= "00000";

                when others =>  state <= (others => '0');
                                baseram_data <= (others => 'Z');
                                baseram_ce <= '1';
                                baseram_oe <= '1';
                                baseram_we <= '1';
                                extraram_data <= (others => 'Z');
                                extraram_ce <= '1';
                                extraram_oe <= '1';
                                extraram_we <= '1';
                                data_ready <= '1';
            end case;
        end if;
    end process;

    process(ope_ce1, ope_ce2, ope_we, baseram_data, extraram_data)
    begin
        if(ope_ce1 = '1' and ope_we = '1') then
            read_data <= baseram_data;
        elsif (ope_ce2 = '1' and ope_we = '1') then
            read_data <= extraram_data;
        else
            read_data <= (others => 'Z');
        end if;
    end process;
            


end Behavioral;
