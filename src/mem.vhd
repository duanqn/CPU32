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
    cp0_status_i: in STD_LOGIC_VECTOR(31 downto 0);
		cp0_cause_i: in STD_LOGIC_VECTOR(31 downto 0);
		cp0_epc_i: in STD_LOGIC_VECTOR(31 downto 0);
		wb_cp0_reg_we: in STD_LOGIC;
		wb_cp0_reg_write_addr: in STD_LOGIC_VECTOR(4 downto 0);
		wb_cp0_reg_data: in STD_LOGIC_VECTOR(31 downto 0);

		excepttype_i: in STD_LOGIC_VECTOR(31 downto 0);
		current_inst_addr_i: in STD_LOGIC_VECTOR(31 downto 0);
		is_in_delayslot_i: in STD_LOGIC;


    mem_addr_o: out STD_LOGIC_VECTOR(31 downto 0);
    mem_we_o: out STD_LOGIC;
    mem_align: out STD_LOGIC_VECTOR(1 downto 0);
    mem_data_o: out STD_LOGIC_VECTOR(31 downto 0);
    mem_ce_o: out STD_LOGIC;

    cp0_reg_we_o: out STD_LOGIC;
		cp0_reg_write_addr_o: out STD_LOGIC_VECTOR(4 downto 0);
		cp0_reg_data_o: out STD_LOGIC_VECTOR(31 downto 0);

    excepttype_o: out STD_LOGIC_VECTOR(31 downto 0);
		current_inst_addr_o: out STD_LOGIC_VECTOR(31 downto 0);
    is_in_delayslot_o: out STD_LOGIC;
		cp0_epc_o: out STD_LOGIC_VECTOR(31 downto 0);

    -- "000": no exception  "001":TLB modified  "010":TLBL  "011":TLBS  "100":ADEL  "101":ADES
    mmu_exc_code: in STD_LOGIC_VECTOR(2 downto 0);
    mmu_badAddr: in STD_LOGIC_VECTOR(31 downto 0);
    badAddr_o: out STD_LOGIC_VECTOR(31 downto 0);

    wd_o: out STD_LOGIC_VECTOR(4 downto 0);
    wreg_o: out STD_LOGIC;
    wdata_o: out STD_LOGIC_VECTOR(31 downto 0);
    hi_o: out STD_LOGIC_VECTOR(31 downto 0);
    lo_o: out STD_LOGIC_VECTOR(31 downto 0);
    whilo_o:out STD_LOGIC;

    -- cp0
    Index_i : in std_logic_vector(31 downto 0);
    EntryLo0_i : in std_logic_vector(31 downto 0);
    EntryLo1_i : in std_logic_vector(31 downto 0);
    PageMask_i : in std_logic_vector(31 downto 0);
    EntryHi_i : in std_logic_vector(31 downto 0);

    tlb_write_struct: out std_logic_vector(TLB_WRITE_STRUCT_WIDTH - 1 downto 0);
    tlb_write_enable: out STD_LOGIC

    );
end mem;

architecture arch of mem is
  signal mem_we: STD_LOGIC;
	signal zero32: STD_LOGIC_VECTOR(31 downto 0);
	signal cp0_status: STD_LOGIC_VECTOR(31 downto 0);
	signal cp0_cause: STD_LOGIC_VECTOR(31 downto 0);
	signal cp0_epc: STD_LOGIC_VECTOR(31 downto 0);
begin

  mem_we_o <= mem_we;
  zero32 <= X"00000000";
  is_in_delayslot_o <= is_in_delayslot_i;
	current_inst_addr_o <= current_inst_addr_i;


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
      mem_align <= ALIGN_TYPE_WORD;
      mem_data_o <= X"00000000";
      mem_ce_o <= '0';
			cp0_reg_we_o <= '0';
			cp0_reg_write_addr_o <= "00000";
			cp0_reg_data_o <= X"00000000";
      tlb_write_enable <= '0';


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
        when EXE_TLBWI_OP =>
          mem_we <= '0';
          mem_addr_o <= X"00000000";
          mem_align <= ALIGN_TYPE_WORD;
          mem_ce_o <= '0';
          mem_data_o <= X"00000000";
          tlb_write_enable <= '1';
          tlb_write_struct <= Index_i(TLB_INDEX_WIDTH-1 downto 0) & EntryHi_i(31 downto 13) & EntryLo0_i(25 downto 6) &
          EntryLo0_i(2 downto 1) & EntryLo1_i(25 downto 6) & EntryLo1_i(2 downto 1);
        when EXE_LB_OP =>
          mem_addr_o <= mem_addr_i;
          mem_we <= '0';
          mem_ce_o <= '1';
          tlb_write_enable <= '0';
          mem_align <= ALIGN_TYPE_BYTE;
          case( mem_addr_i(1 downto 0) ) is
            when "00" =>
              wdata_o <= (31 downto 8 => mem_data_i(31)) & mem_data_i(31 downto 24);
            when "01" =>
              wdata_o <= (31 downto 8 => mem_data_i(23)) & mem_data_i(23 downto 16);
            when "10" =>
              wdata_o <= (31 downto 8 => mem_data_i(15)) & mem_data_i(15 downto 8);
            when "11" =>
              wdata_o <= (31 downto 8 => mem_data_i(7)) & mem_data_i(7 downto 0);
            when others =>
              wdata_o <= X"00000000";
          end case;
        when EXE_LBU_OP =>
          mem_addr_o <= mem_addr_i;
          mem_we <= '0';
          mem_ce_o <= '1';
          tlb_write_enable <= '0';
          mem_align <= ALIGN_TYPE_BYTE;
          case( mem_addr_i(1 downto 0) ) is
            when "00" =>
              wdata_o <= (31 downto 8 => '0') & mem_data_i(31 downto 24);
            when "01" =>
              wdata_o <= (31 downto 8 => '0') & mem_data_i(23 downto 16);
            when "10" =>
              wdata_o <= (31 downto 8 => '0') & mem_data_i(15 downto 8);
            when "11" =>
              wdata_o <= (31 downto 8 => '0') & mem_data_i(7 downto 0);
            when others =>
              wdata_o <= X"00000000";
          end case;
        when EXE_LHU_OP =>
          mem_addr_o <= mem_addr_i;
          mem_we <= '0';
          mem_ce_o <= '1';
          tlb_write_enable <= '0';
          mem_align <= ALIGN_TYPE_HALF_WORD;
          case( mem_addr_i(1 downto 0) ) is
            when "00" =>
              wdata_o <= (31 downto 16 => '0') & mem_data_i(31 downto 16);
            when "10" =>
              wdata_o <= (31 downto 16 => '0') & mem_data_i(15 downto 0);
            when others =>
              wdata_o <= X"00000000";
          end case;
        when EXE_LW_OP =>
          mem_addr_o <= mem_addr_i;
          mem_we <= '0';
          wdata_o <= mem_data_i;
          mem_align <= ALIGN_TYPE_WORD;
          mem_ce_o <= '1';
          tlb_write_enable <= '0';
        when EXE_SB_OP =>
          mem_addr_o <= mem_addr_i;
          mem_we <= '1';
          mem_data_o <= reg2_i(7 downto 0) & reg2_i(7 downto 0) & reg2_i(7 downto 0) & reg2_i(7 downto 0);
          mem_ce_o <= '1';
          tlb_write_enable <= '0';
          mem_align <= ALIGN_TYPE_BYTE;
          case( mem_addr_i(1 downto 0) ) is
            when "00" =>
              mem_align <= "1000";
            when "01" =>
              mem_align <= "0100";
            when "10" =>
              mem_align <= "0010";
            when "11" =>
              mem_align <= "0001";
            when others =>
              mem_align <= "0000";
          end case;
        when EXE_SW_OP =>
          mem_addr_o <= mem_addr_i;
          mem_we <= '1';
          mem_data_o <= reg2_i;
          mem_align <= ALIGN_TYPE_WORD;
          mem_ce_o <= '1';
          tlb_write_enable <= '0';
        when others =>
          mem_we <= '0';
          mem_addr_o <= X"00000000";
          mem_align <= ALIGN_TYPE_WORD;
          mem_ce_o <= '0';
          mem_data_o <= X"00000000";
          tlb_write_enable <= '0';
      end case ;
    end if;
  end process ; -- identifier

  --read latest cp0_status
	process (rst, wb_cp0_reg_we, wb_cp0_reg_write_addr, wb_cp0_reg_data, cp0_status, cp0_status_i)
	begin
		if (rst = '0') then
			cp0_status <= X"00000000";
		elsif (wb_cp0_reg_we = '1' AND wb_cp0_reg_write_addr = "01100") then
			cp0_status <= wb_cp0_reg_data;
		else
			cp0_status <= cp0_status_i;
		end if;
	end process;

	--read latest cp0_epc
	process (rst, wb_cp0_reg_we, wb_cp0_reg_data, wb_cp0_reg_write_addr, cp0_epc, cp0_epc_i)
	begin
		if(rst = '0') then
			cp0_epc <= X"00000000";
		elsif (wb_cp0_reg_we = '1' and wb_cp0_reg_write_addr = "01110") then
			cp0_epc <= wb_cp0_reg_data;
		else
			cp0_epc <= cp0_epc_i;
		end if;
	end process;

  cp0_epc_o <= cp0_epc;

  --read latest cp0_cause
	process (rst, wb_cp0_reg_we, wb_cp0_reg_write_addr, wb_cp0_reg_data, cp0_cause, cp0_cause_i)
	begin
		if(rst = '0') then
			cp0_cause <= X"00000000";
		elsif (wb_cp0_reg_we = '1' and wb_cp0_reg_write_addr = "01101") then
			cp0_cause(9 downto 8) <= wb_cp0_reg_data(9 downto 8);
			cp0_cause(22) <= wb_cp0_reg_data(22);
			cp0_cause(23) <= wb_cp0_reg_data(23);
		else
			cp0_cause <= cp0_cause_i;
	  end if;
  end process;

	process(rst, excepttype_i, cp0_cause, cp0_status, current_inst_addr_i)
  begin
	  if(rst = '0') then
			excepttype_o <= X"00000000";
		else
			excepttype_o <= X"00000000";
			if (current_inst_addr_i /= X"00000000") then
				if ((cp0_cause(15 downto 8) and (cp0_status(15 downto 8))) /= "00000000" and (cp0_status(1) = '0') and (cp0_status(0) = '1')) then
					excepttype_o <= X"00000007"; -- Interrupt
				elsif (excepttype_i(8) = '1') then
					excepttype_o <= X"00000008"; -- Syscall
				elsif (excepttype_i(9) = '1') then
					excepttype_o <= X"0000000a"; -- Invalid instruction
				elsif (excepttype_i(11) = '1') then
					excepttype_o <= X"0000000c"; -- Overflow
				elsif (excepttype_i(12) = '1') then
					excepttype_o <= X"0000000e"; -- ERET
        elsif (mmu_exc_code = "100") then
          excepttype_o <= x"00000004";  -- ADEL
          badAddr_o <= mmu_badAddr;
        elsif (mmu_exc_code = "101") then
          excepttype_o <= x"00000005";  -- ADES
          badAddr_o <= mmu_badAddr;
        elsif (mmu_exc_code = "010") then
          excepttype_o <= x"00000002";  -- TLBL
          badAddr_o <= mmu_badAddr;
        elsif (mmu_exc_code = "011") then
          excepttype_o <= x"00000003";  -- TLBS
          badAddr_o <= mmu_badAddr;
        elsif (mmu_exc_code = "001") then
          excepttype_o <= x"00000001";  -- TLB modify
          badAddr_o <= mmu_badAddr;
				end if;
		  end if;
		end if;
	end process;

	mem_we_o <= mem_we and (not (excepttype(0)
or excepttype(1)
or excepttype(2)
or excepttype(3)
or excepttype(4)
or excepttype(5)
or excepttype(6)
or excepttype(7)
or excepttype(8)
or excepttype(9)
or excepttype(10)
or excepttype(11)
or excepttype(12)
or excepttype(13)
or excepttype(14)
or excepttype(15)
or excepttype(16)
or excepttype(17)
or excepttype(18)
or excepttype(19)
or excepttype(20)
or excepttype(21)
or excepttype(22)
or excepttype(23)
or excepttype(24)
or excepttype(25)
or excepttype(26)
or excepttype(27)
or excepttype(28)
or excepttype(29)
or excepttype(30)
or excepttype(31)));
end architecture ; -- arch
