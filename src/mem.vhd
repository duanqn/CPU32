LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.CPU32.all;

ENTITY mem is
	port(
    rst: in STD_LOGIC;
		wd_i: in STD_LOGIC_VECTOR(4 downto 0);
		wreg_i: in STD_LOGIC;
		wdata_i: in STD_LOGIC_VECTOR(31 downto 0);
    hi_i: in STD_LOGIC_VECTOR(31 downto 0);
    lo_i: in STD_LOGIC_VECTOR(31 downto 0);
    whilo_i: in STD_LOGIC;

    aluop_i: in STD_LOGIC_VECTOR(7 downto 0);
    mem_addr_i: in STD_LOGIC_VECTOR(31 downto 0);
    reg2_i: in STD_LOGIC_VECTOR(31 downto 0);

    mem_data_i: in STD_LOGIC_VECTOR(31 downto 0);

		cp0_reg_we_i: in STD_LOGIC;
		cp0_reg_write_addr_i: in STD_LOGIC_VECTOR(4 downto 0);
		cp0_reg_data_i: in STD_LOGIC_VECTOR(31 downto 0);


    mem_addr_o: out STD_LOGIC_VECTOR(31 downto 0);
    mem_we_o: out STD_LOGIC;
    mem_sel_o: out STD_LOGIC_VECTOR(3 downto 0);
    mem_data_o: out STD_LOGIC_VECTOR(31 downto 0);
    mem_ce_o: out STD_LOGIC;

    cp0_reg_we_o: out  STD_LOGIC;
		cp0_reg_write_addr_o: out STD_LOGIC_VECTOR(4 downto 0);
		cp0_reg_data_o: out STD_LOGIC_VECTOR(31 downto 0);

    wd_o: out STD_LOGIC_VECTOR(4 downto 0);
    wreg_o: out STD_LOGIC;
    wdata_o: out STD_LOGIC_VECTOR(31 downto 0);
    hi_o: out STD_LOGIC_VECTOR(31 downto 0);
    lo_o: out STD_LOGIC_VECTOR(31 downto 0);
    whilo_o:out STD_LOGIC
    );
end mem;

architecture arch of mem is
  signal mem_we: STD_LOGIC;
begin

  mem_we_o <= mem_we;

  identifier : process(rst, wd_i, wreg_i, wdata_i, hi_i, lo_i, whilo_i, aluop_i, mem_addr_i, mem_data_i, reg2_i)
  begin
    if(rst='0') then
      wd_o <= "00000";
      wreg_o <= '0';
      wdata_o <= x"00000000";
      hi_o <= x"00000000";
      lo_o <= x"00000000";
      whilo_o <= '0';
      mem_addr_o <= X"00000000";
      mem_we <= '0';
      mem_sel_o <= "0000";
      mem_data_o <= X"00000000";
      mem_ce_o <= '0';
			cp0_reg_we_o <= '0';
			cp0_reg_write_addr_o <= "00000";
			cp0_reg_data_o <= X"00000000";

    else
      wd_o <= wd_i;
      wreg_o <= wreg_i;
      wdata_o <= wdata_i;
      hi_o <= hi_i;
      lo_o <= lo_i;
      whilo_o <= whilo_i;
		  cp0_reg_we_o <= cp0_reg_we_i;
			cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
			cp0_reg_data_o <= cp0_reg_data_i;
      case( aluop_i ) is
        when EXE_LB_OP =>
          mem_addr_o <= mem_addr_i;
          mem_we <= '0';
          mem_ce_o <= '1';
          case( mem_addr_i(1 downto 0) ) is
            when "00" =>
              wdata_o <= (31 downto 8 => mem_data_i(31)) & mem_data_i(31 downto 24);
              mem_sel_o <= "1000";
            when "01" =>
              wdata_o <= (31 downto 8 => mem_data_i(23)) & mem_data_i(23 downto 16);
              mem_sel_o <= "0100";
            when "10" =>
              wdata_o <= (31 downto 8 => mem_data_i(15)) & mem_data_i(15 downto 8);
              mem_sel_o <= "0010";
            when "11" =>
              wdata_o <= (31 downto 8 => mem_data_i(7)) & mem_data_i(7 downto 0);
              mem_sel_o <= "0001";
            when others =>
              wdata_o <= X"00000000";
              mem_sel_o <= "1111";
          end case;
        when EXE_LBU_OP =>
          mem_addr_o <= mem_addr_i;
          mem_we <= '0';
          mem_ce_o <= '1';
          case( mem_addr_i(1 downto 0) ) is
            when "00" =>
              wdata_o <= (31 downto 8 => '0') & mem_data_i(31 downto 24);
              mem_sel_o <= "1000";
            when "01" =>
              wdata_o <= (31 downto 8 => '0') & mem_data_i(23 downto 16);
              mem_sel_o <= "0100";
            when "10" =>
              wdata_o <= (31 downto 8 => '0') & mem_data_i(15 downto 8);
              mem_sel_o <= "0010";
            when "11" =>
              wdata_o <= (31 downto 8 => '0') & mem_data_i(7 downto 0);
              mem_sel_o <= "0001";
            when others =>
              wdata_o <= X"00000000";
              mem_sel_o <= "1111";
          end case;
        when EXE_LHU_OP =>
          mem_addr_o <= mem_addr_i;
          mem_we <= '0';
          mem_ce_o <= '1';
          case( mem_addr_i(1 downto 0) ) is
            when "00" =>
              wdata_o <= (31 downto 16 => '0') & mem_data_i(31 downto 16);
              mem_sel_o <= "1100";
            when "10" =>
              wdata_o <= (31 downto 16 => '0') & mem_data_i(15 downto 0);
              mem_sel_o <= "0011";
            when others =>
              wdata_o <= X"00000000";
              mem_sel_o <= "1111";
          end case;
        when EXE_LW_OP =>
          mem_addr_o <= mem_addr_i;
          mem_we <= '0';
          wdata_o <= mem_data_i;
          mem_sel_o <= "1111";
          mem_ce_o <= '1';

        when EXE_SB_OP =>
          mem_addr_o <= mem_addr_i;
          mem_we <= '1';
          mem_data_o <= reg2_i(7 downto 0) & reg2_i(7 downto 0) & reg2_i(7 downto 0) & reg2_i(7 downto 0);
          mem_ce_o <= '1';
          case( mem_addr_i(1 downto 0) ) is
            when "00" =>
              mem_sel_o <= "1000";
            when "01" =>
              mem_sel_o <= "0100";
            when "10" =>
              mem_sel_o <= "0010";
            when "11" =>
              mem_sel_o <= "0001";
            when others =>
              mem_sel_o <= "0000";
          end case;
        when EXE_SW_OP =>
          mem_addr_o <= mem_addr_i;
          mem_we <= '1';
          mem_data_o <= reg2_i;
          mem_sel_o <= "1111";
          mem_ce_o <= '1';
        when others =>
          mem_we <= '0';
          mem_addr_o <= X"00000000";
          mem_sel_o <= "1111";
          mem_ce_o <= '0';
          mem_data_o <= X"00000000";
      end case ;
    end if;
  end process ; -- identifier

end architecture ; -- arch
