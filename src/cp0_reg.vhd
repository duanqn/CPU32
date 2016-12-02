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
    mmu_int_i : in std_logic_vector(3 downto 0);  -- Cause(14 downto 11)
    we_i : in std_logic;
    waddr_i : in std_logic_vector(4 downto 0);
    data_i : in std_logic_vector(31 downto 0);

    -- output ports

    data_o : out std_logic_vector(31 downto 0);

    Index_o : out std_logic_vector(31 downto 0);
    EntryLo0_o : out std_logic_vector(31 downto 0);
    EntryLo1_o : out std_logic_vector(31 downto 0);
    PageMask_o : out std_logic_vector(31 downto 0);
    EntryHi_o : out std_logic_vector(31 downto 0);

    Cause_o : out std_logic_vector(31 downto 0);
    EPC_o : out std_logic_vector(31 downto 0);
    Status_o : out std_logic_vector(31 downto 0);

    --BadVAddr_o : out std_logic_vector(31 downto 0);
    --Count_o : out std_logic_vector(31 downto 0);
    --Compare_o : out std_logic_vector(31 downto 0);

    EBase_o : out std_logic_vector(31 downto 0);
    --timer_int_o : out std_logic;

    excepttype_i: in STD_LOGIC_VECTOR(31 downto 0);
    current_inst_address_i: in STD_LOGIC_VECTOR(31 downto 0);
    badAddr_i: in STD_LOGIC_VECTOR(31 downto 0);
    is_in_delayslot_i: in STD_LOGIC
  );
end cp0_reg;

architecture behave of cp0_reg is
  type register_bank is array(31 downto 0) of std_logic_vector(31 downto 0);
  signal register_values: register_bank := (11=>x"00FFFFFF", 12=>x"10000000", 15=>x"80000180",others => (others => '0'));

begin

  Index_o <= register_values(0);
  EntryLo0_o <= register_values(2);
  EntryLo1_o <= register_values(3);
  PageMask_o <= register_values(5);
  BadVAddr_o <= register_values(8);
  Count_o <= register_values(9);
  EntryHi_o <= register_values(10);
  Compare_o <= register_values(11);
  Status_o <= register_values(12);
  Cause_o <= register_values(13);
  EPC_o <= register_values(14);
  EBase_o <= register_values(15);

  register_values(13)(14 downto 11) <= mmu_int_i;
  timer_int_o <= register_values(13)(10);

  write_operation : process(rst, clk, we_i, waddr_i, data_i)
  begin
    if(rst = '0') then

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
      --Compare init to zero, handled by OS
      register_values(11) <= X"00000000";
      --Status_o init
      register_values(12) <= X"10000000";
      --Cause_o init
      register_values(13)(31 downto 16) <= x"0000";
      register_values(13)(15) <= '0';
      register_values(13)(9 downto 0) <= "0000000000";
      --EPC_o init
      register_values(14) <= X"00000000";
      --EBase_o init(not sure on the 9 to 0 bits)
      register_values(15) <= X"00000000";

      register_values(1) <= X"00000000";
      register_values(4) <= X"00000000";
      register_values(5) <= X"00000000";
      register_values(6) <= X"00000000";
      register_values(7) <= X"00000000";
      for i in 16 to 31 loop
        register_values(i) <= (others => '0');
      end loop;

    elsif rising_edge(clk) then

      if(register_values(11) /= X"00000000" and register_values(9) = register_values(11)) then
        if(we_i = '1' and waddr_i /= "01011") then
          register_values(13)(10) <= '1';
          -- reset operation done by OS
        elsif (we_i = '0') then
          register_values(13)(10) <= '1';
        else
          register_values(13)(10) <= '0';
        end if;
      else
        register_values(13)(10) <= '0';
        register_values(9) <= register_values(9) + 1;
      end if;

      if(excepttype_i = x"00000000") then
        if(we_i = '1' and waddr_i = "01000") then
          register_values(8) <= data_i;
        else
          register_values(8) <= badAddr_i;
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
            --when "01000" => register_values(8) <= data_i;
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
            when "01111" => register_values(15) <= "10"&data_i(29 downto 12)&"00"&"0110000000";
            when others => null;
          end case;
        end if;
      else
        if(we_i = '1' and waddr_i = "01000") then
          register_values(8) <= data_i;
        else
          register_values(8) <= badAddr_i;
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
            --when "01000" => register_values(8) <= data_i;
            --Count
            when "01001" => register_values(9) <= data_i;
            --EntryHi
            when "01010" => register_values(10)(31 downto 13) <= data_i(31 downto 13);
                            register_values(10)(7 downto 0) <= data_i(7 downto 0);
            --Compare
            when "01011" => register_values(11) <= data_i;
            --EBase
            when "01111" => register_values(15) <= "10"&data_i(29 downto 12)&"00"&"0110000000";
            when others => null;
          end case;
        end if;

        case excepttype_i is
          when x"00000007" => --Interrupt
            register_values(12)(1) <= '1';
            register_values(13)(6 downto 2) <= "00000";
            if(is_in_delayslot_i = '1') then
              register_values(14) <= current_inst_address_i - 4;
              register_values(13)(31) <= '1';
            else
              register_values(14) <= current_inst_address_i;
              register_values(13)(31) <= '0';
            end if;
          when x"00000008" => --Syscall

            if(register_values(12)(1) = '0') then
              if(is_in_delayslot_i = '1') then
                register_values(14) <= current_inst_address_i - 4;
                register_values(13)(31) <= '1';
              else
                register_values(14) <= current_inst_address_i;
                register_values(13)(31) <= '0';
              end if;
              register_values(12)(1) <= '1';
              register_values(13)(6 downto 2) <= "01000";
            else
              register_values(13)(6 downto 2) <= "01000";
            end if;

          when x"0000000A" => --Invalid instruction
            if(register_values(12)(1) = '0') then
              if(is_in_delayslot_i = '1') then
                register_values(14) <= current_inst_address_i - 4;
                register_values(13)(31) <= '1';
              else
                register_values(14) <= current_inst_address_i;
                register_values(13)(31) <= '0';
              end if;
              register_values(12)(1) <= '1';
              register_values(13)(6 downto 2) <= "01010";
            else
              register_values(13)(6 downto 2) <= "01010";
            end if;
          when x"0000000D" => --Trap
            if(register_values(12)(1) = '0') then
              if(is_in_delayslot_i = '1') then
                register_values(14) <= current_inst_address_i - 4;
                register_values(13)(31) <= '1';
              else
                register_values(14) <= current_inst_address_i;
                register_values(13)(31) <= '0';
              end if;
              register_values(12)(1) <= '1';
              register_values(13)(6 downto 2) <= "01101";
            else
              register_values(13)(6 downto 2) <= "01101";
          end if;

          when x"0000000C" => --Overflow
            if(register_values(12)(1) = '0') then
              if(is_in_delayslot_i = '1') then
                register_values(14) <= current_inst_address_i - 4;
                register_values(13)(31) <= '1';
              else
                register_values(14) <= current_inst_address_i;
                register_values(13)(31) <= '0';
              end if;
              register_values(12)(1) <= '1';
              register_values(13)(6 downto 2) <= "01100";
            else
              register_values(13)(6 downto 2) <= "01100";
            end if;

          when x"00000001" => --TLB modify
            if(register_values(12)(1) = '0') then
              if(is_in_delayslot_i = '1') then
                register_values(14) <= current_inst_address_i - 4;
                register_values(13)(31) <= '1';
              else
                register_values(14) <= current_inst_address_i;
                register_values(13)(31) <= '0';
              end if;
              register_values(12)(1) <= '1';
              register_values(13)(6 downto 2) <= "00001";
            else
              register_values(13)(6 downto 2) <= "00001";
            end if;

          when x"00000002" => --TLBL
            if(register_values(12)(1) = '0') then
              if(is_in_delayslot_i = '1') then
                register_values(14) <= current_inst_address_i - 4;
                register_values(13)(31) <= '1';
              else
                register_values(14) <= current_inst_address_i;
                register_values(13)(31) <= '0';
              end if;
              register_values(12)(1) <= '1';
              register_values(13)(6 downto 2) <= "00010";
            else
              register_values(13)(6 downto 2) <= "00010";
            end if;

          when x"00000003" => --TLBS
            if(register_values(12)(1) = '0') then
              if(is_in_delayslot_i = '1') then
                register_values(14) <= current_inst_address_i - 4;
                register_values(13)(31) <= '1';
              else
                register_values(14) <= current_inst_address_i;
                register_values(13)(31) <= '0';
              end if;
              register_values(12)(1) <= '1';
              register_values(13)(6 downto 2) <= "00011";
            else
              register_values(13)(6 downto 2) <= "00011";
            end if;

          when x"00000004" => --ADEL
            if(register_values(12)(1) = '0') then
              if(is_in_delayslot_i = '1') then
                register_values(14) <= current_inst_address_i - 4;
                register_values(13)(31) <= '1';
              else
                register_values(14) <= current_inst_address_i;
                register_values(13)(31) <= '0';
              end if;
              register_values(12)(1) <= '1';
              register_values(13)(6 downto 2) <= "00100";
            else
              register_values(13)(6 downto 2) <= "00100";
            end if;

          when x"00000005" => --ADES
            if(register_values(12)(1) = '0') then
              if(is_in_delayslot_i = '1') then
                register_values(14) <= current_inst_address_i - 4;
                register_values(13)(31) <= '1';
              else
                register_values(14) <= current_inst_address_i;
                register_values(13)(31) <= '0';
              end if;
              register_values(12)(1) <= '1';
              register_values(13)(6 downto 2) <= "00101";
            else
              register_values(13)(6 downto 2) <= "00101";
            end if;

          when x"0000000E" => --Eret
            register_values(12)(1) <= '0';

          when others => NULL;
        end case;
      end if;

    end if; -- rising_edge
  end process;

  read_operation : process(clk, rst, raddr_i, register_values)
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
