library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.CPU32.all;

entity serial2flash is
    Port ( clk : in  STD_LOGIC;
           rst : in STD_LOGIC;
           data_in : in STD_LOGIC_VECTOR (15 downto 0);
           data_out : out  STD_LOGIC_VECTOR (15 downto 0);

           write_enable: in std_logic;

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
           flash_control_we: out std_logic
          );
end serial2flash;

architecture Behavioral of serial2flash is
signal addr : std_logic_vector(21 downto 0) := (others => '0');
begin
    flash_control_ce0 <= '0';
    flash_control_ce1 <= '0';
    flash_control_ce2 <= '0';
    flash_control_byte <= '1';
    flash_control_vpen <= '1';
    flash_control_rp <= '1';

    process (clk, rst)
    variable state: integer := 0;
    begin
        if rst = '0' then
          addr <= (others => '0');
          state := 0;
          flash_control_oe <= '1';
          flash_control_we <= '1';
          flash_data <= (others => 'Z');
        elsif (clk'event and clk = '1') then
            case (state) is
                -- initial state
                -- priority: read > write > erase
                -- read states: 0x, write states: 1x, erase states: 2x, wait states: 3x
                when 0 =>
                    if (write_enable = '1') then
                    -- write state 0
                        flash_control_we <= '0';
                        flash_data <= X"0040";
                        data_ready <= '0';
                        state := 11;
                    else
                        data_ready <= '1';
                        flash_data <= X"0000";
                        state := 0;
                    end if;
                -- read state 1
                when 1 =>
                    flash_control_we <= '1';
                    state := 2;
                -- read state 2
                when 2 =>
                    flash_data <= (others => 'Z');
                    state := 3;
                -- read state 3
                when 3 =>
                    flash_control_oe <= '0';
                    flash_addr <= addr & '0';
                    state := 4;
                -- read state 4
                when 4 =>
                    state := 5;
                    data_out <= flash_data;
                    flash_control_oe <= '1';
                    data_ready <= '1';
                when 5 =>
                    state := 0;

                -- write state 1
                when 11 =>
                    flash_control_we <= '1';
                    state := 12;
                -- write state 2
                when 12 =>
                    flash_control_we <= '0';
                    flash_data <= data_in;
                    flash_addr <= addr & '0';
                    state := 13;
                -- write state 3
                when 13 =>
                    flash_control_we <= '1';
                    state := 31;

                -- erase state 1
                when 21 =>
                    flash_control_we <= '1';
                    state := 22;
                -- erase state 2
                when 22 =>
                    flash_control_we <= '0';
                    flash_addr <= addr & '0';
                    flash_data <= X"00D0";
                    state := 23;
                -- erase state 3
                when 23 =>
                    flash_control_we <= '1';
                    state := 31;



                -- wait state 1
                when 31 =>
                    flash_data <= X"0070";
                    flash_control_we <= '0';
                    state := 32;
                -- wait state 2
                when 32 =>
                    flash_control_we <= '1';
                    state := 33;
                -- wait state 3
                when 33 =>
                    flash_data <= (others => 'Z');
                    flash_control_oe <= '0';
                    state := 34;
                -- wait state 4
                when 34 =>
                    flash_control_oe <= '1';
                    if (flash_data(7) = '1') then
                      flash_control_we <= '0';
                      flash_data <= X"00FF";
                      data_ready <= '0';
                      addr <= addr + "0000000000000000000001";
                      state := 1;
                    else
                        state := 31;
                    end if;
                when others =>
                    state := 0;
            end case;
        end if;
    end process;
end Behavioral;
