library ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA is port(
  clk : in std_logic;
  rst : in std_logic;
  Hs : out std_logic;
  Vs : out std_logic;
  Lcd_R : out std_logic_vector (2 downto 0);
  Lcd_G : out std_logic_vector (2 downto 0);
  Lcd_B : out std_logic_vector (2 downto 0)
);
end VGA;

architecture behave of VGA is
signal clk_2 : STD_LOGIC := '0';
signal vector_x : STD_LOGIC_VECTOR (9 downto 0);
signal vector_y : STD_LOGIC_VECTOR (9 downto 0);
signal r, g, b : STD_LOGIC_VECTOR (2 downto 0);
signal Hs_1, Vs_1 : STD_LOGIC;

begin
  process(clk, rst)
  begin
    if rst = '0' then
      clk_2 <= '0';
    elsif clk'event and clk = '1' then
      clk_2 <= not clk_2;
    end if;
  end process;

  process(clk_2, rst)
  begin
    if (rst = '0') then
      vector_x <= (others => '0');
    elsif (clk_2'event and clk_2 = '1') then
      if(vector_x = 799) then
        vector_x <= (others => '0');
      else
        vector_x <= vector_x + 1;
      end if;
    end if;
  end process;

  process(clk_2, rst)
  begin
    if(rst = '0') then
      vector_y <= (others => '0');
    elsif (clk_2'event and clk_2 = '1') then
      if (vector_x = 799) then
        if (vector_y = 524) then
          vector_y <= (others => '0');
        else
          vector_y <= vector_y + 1;
        end if;
      end if;
    end if;
  end process;

  process(clk_2, rst)
  begin
    if (rst = '0') then
      Hs_1 <= '1';
    elsif (clk_2'event and clk_2 = '1') then
      if (vector_x >= 656 and vector_x <= 751) then
        Hs_1 <= '0';
      else
        Hs_1 <= '1';
      end if;
    end if;
  end process;

  process(clk_2, rst)
  begin
    if (rst = '0') then
      Vs_1 <= '1';
    elsif (clk_2'event and clk_2 = '1') then
      if (vector_y >= 490 and vector_y <= 491) then
        Vs_1 <= '0';
      else
        Vs_1 <= '1';
      end if;
    end if;
  end process;

  process(clk_2, rst)
  begin
    if (rst = '0') then
      Hs <= '0';
    elsif (clk_2'event and clk_2 = '1') then
      Hs <= Hs_1;
    end if;
  end process;

  process(clk_2, rst)
  begin
    if(rst = '0') then
      Vs <= '0';
    elsif (clk_2'event and clk_2 = '1') then
      Vs <= Vs_1;
    end if;
  end process;

  process(clk_2, rst, vector_x, vector_y)
  begin
    if (rst = '0') then
      r <= "000";
      g <= "000";
      b <= "000";
    elsif (clk_2'event and clk_2 = '1') then
      if (vector_x > 639 and vector_y > 479) then
        r <= "000";
        g <= "000";
        b <= "000";
      elsif ((vector_x >= 175 and vector_x <= 177) or (vector_x >= 239 and vector_x <= 241)
				  or (vector_x >= 303 and vector_x <= 305) or (vector_x >= 367 and vector_x <= 369)
				  or (vector_x >= 431 and vector_x <= 433)) and (vector_y >= 31 and vector_y <= 161) then
					  r <= "100";
					  g <= "100";
					  b <= "100";
		  elsif ((vector_y >= 31 and vector_y <= 33) or (vector_y >= 63 and vector_y <= 65)
				  or (vector_y >= 95 and vector_y <= 97) or (vector_y >= 127 and vector_y <= 129)
				  or (vector_y >= 159 and vector_y <= 161)) and (vector_x >= 175 and vector_x <= 433) then
					  r <= "100";
					  g <= "100";
					  b <= "100";
      else
        r <= "000";
        g <= "000";
        b <= "000";
      end if;
    end if;
  end process;

  process (Hs_1, Vs_1, r, g, b)
  begin
    if (Hs_1 = '1' and Vs_1 = '1') then
      Lcd_R <= r;
      Lcd_G <= g;
      Lcd_B <= b;
    else
      Lcd_R <= (others => '0');
      Lcd_G <= (others => '0');
      Lcd_B <= (others => '0');
    end if;
  end process;

end behave;
