library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.CPU32.ALL;

entity cp0_reg is
  PORT(
    -- input ports
    clk : in std_logic;
    rst : in std_logic;
    raddr_i : in std_logic_vector(4 downto 0);
    int_i : in std_logic_vector(5 downto 0);
    we_i in : std_logic;
    waddr_i : in std_logic_vector(4 downto 0);
    data_i : in std_logic_vector(31 downto 0);

    -- output ports
    data_o : out std_logic_vector(31 downto 0);
    Index_o : out std_logic_vector(31 downto 0);
    EntryLo0_o : out std_logic_vector(31 downto 0);
    EntryLo1_o : out std_logic_vector(31 downto 0);
    BadVAddr_o : out std_logic_vector(31 downto 0);
    Count_o : out std_logic_vector(31 downto 0);
    EntryHi_o : out std_logic_vector(31 downto 0);
    Compare_o : out std_logic_vector(31 downto 0);
    Status_o : out std_logic_vector(31 downto 0);
    Cause_o : out std_logic_vector(31 downto 0);
    EPC_o : out std_logic_vector(31 downto 0);
    EBase_o : out std_logic_vector(31 downto 0);
    timer_int_o : out std_logic
  );
end cp0_reg;

architecture behave of cp0_reg is
  type register_bank is array(31 downto 0) of std_logic_vector(31 downto 0);
  signal register_values: register_bank := (others => (others => '0'));

begin

  Index_o <= register_values(0);
  EntryLo0_o <= register_values(2);
  EntryLo1_o <= register_values(3);
  BadVAddr_o <= register_values(8);
  Count_o <= register_values(9);
  EntryHi_o <= register_values(10);
  Compare_o <= register_values(11);
  Status_o <= register_values(12);
  Cause_o <= register_values(13);
  EPC_o <= register_values(14);
  EBase_o <= register_values(15);

  write_operation : process(clk)
  begin
    if(rst = '0') then
      for i in 0 to 31 loop
        register_values(i) <= (others => '0');
      end loop;
      --Index init
      register_values(0) <= X"00000000";
      --EntryLo0_o + EntryLo1_o init
      register_values(2) <= X"00000000";
      register_values(3) <= X"00000000";
      --BadVAddr_o init
      register_values(8) <= X"00000000";
      --Count_o init
      register_values(9) <= X"00000000";
      --EntryHi_o init
      register_values(10) <= X"00000000";
      --Compare init to be set by myself(not X"00000000")
      register_values(11) <= X"11111111";
      --Status_o init
      register_values(12) <= X"10000000";
      --Cause_o init
      register_values(13) <= X"00000000";
      --EPC_o init
      register_values(14) <= X"00000000";
      --EBase_o init(not sure on the 9 to 0 bits)
      register_values(15) <= X"80000180";

    elsif rising_edge(clk) then

      register_values(12) <= register_values(12) + 1;
      register_values(13)(15 downto 10) <= int_i;

      if(register_values(11) /= X"00000000" and register_values(9) = register_values(11)) then
        if(we_i = '1' and waddr_i /= "01011") then
          timer_int_o <= '1';
        elsif (we_i = '0') then
          timer_int_o <= '1';
        else
          timer_int_o <= '0';
        end if;
      end if;

      if(we_i = '1') then
        case waddr_i is
          --Index
          when "00000" => register_values(0)(31) <= data_i(31);
                          register_values(0)(5 downto 0) <= data_i(5 downto 0);
          --EntryLo0
          when "00010" => register_values(2)(25 downto 0) <= data_i(25 downto 0);
          --EntryLo1
          when "00011" => register_values(3)(25 downto 0) <= data_i(25 downto 0);
          --BadVAddr
          when "01000" => register_values(8) <= data_i;
          --Count
          when "01001" => register_values(9) <= data_i;
          --EntryHi
          when "01010" => register_values(10)(31 downto 13) <= data_i(31 downto 13);
                          register_values(10)(7 downto 0) <= data_i(7 downto 0);
          --Compare
          when "01011" => register_values(11) <= data_i;
          --Status
          when "01100" => register_values(12) <= data_i;
          --EPC
          when "01110" => register_values(14) <= data_i;
          --Cause
          when "01101" => register_values(13)(9 downto 8) <= data_i(9 downto 8);
                          register_values(13)(23) <= data_i(23);
                          register_values(13)(22) <= data_i(22);
                          register_values(13)(27) <= data_i(27);
          --EBase
          when "01111" => register_values(15)(29 downto 12) <= data_i(29 downto 12);
          when others => null;
        end case;
      end if;
    end if;
  end process;

  read_operation : process(clk, rst)
    begin
      if (rst = '1') then
        data_o <= X"00000000";
      else
        case( raddr_i ) is
          when "00000" => data_o <= register_values(0);
          when "00010" => data_o <= register_values(2);
          when "00011" => data_o <= register_values(3);
          when "01000" => data_o <= register_values(8);
          when "01001" => data_o <= register_values(9);
          when "01010" => data_o <= register_values(10);
          when "01011" => data_o <= register_values(11);
          when "01100" => data_o <= register_values(12);
          when "01101" => data_o <= register_values(13);
          when "01110" => data_o <= register_values(14);
          when "01111" => data_o <= register_values(15);
          when others => data_o <= X"00000000";
        end case;
      end if;
  end process;
end architecture;