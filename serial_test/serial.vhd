LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
use work.CPU32.all;

entity serial is
  PORT (
    clk:in STD_LOGIC;
    rst:in STD_LOGIC;
    switch:in STD_LOGIC_VECTOR(7 downto 0);
    light:out STD_LOGIC_VECTOR(7 downto 0);
    data:inout STD_LOGIC_VECTOR(7 downto 0);
    ram1OE:out STD_LOGIC;
    ram1WE:out STD_LOGIC;
    ram1EN:out STD_LOGIC;
    data_ready:in STD_LOGIC;
    rdn:out STD_LOGIC;
    tbre:in STD_LOGIC;
    tsre:in STD_LOGIC;
    wrn:out STD_LOGIC;
    
  );
end serial;

architecture behave of serial is
signal state:STD_LOGIC_VECTOR(1 downto 0) := "00";
begin
  ram1OE <= '1';
  ram1WE <= '1';
  ram1EN <= '1';
  process (rst, clk, state)
  begin
    if rst = '0' then
      light <= "00000000";
      rdn <= '1';
      wrn <= '1';
      
    elsif clk'event and clk = '1' then
      case state is
        when "01" =>
          data <= switch;
          wrn <= '0';
          state <= "11";
        when "11" =>
          wrn <= '1';
          state <= "10";
        when "10" =>
          if tbre = '1' then
            state <= "00";
          else
            state <= "10";
          end if;
        when "00" =>
          if tbse = '1' then
           state <= "01";
          else
            state <= "00";
          end if;
        when others=>NULL;
      end case;
    end if;
  end
end behave;