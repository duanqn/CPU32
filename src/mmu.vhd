library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.CPU32.ALL;


entity mmu is
port(
  clk : in std_logic;
  rst : in std_logic;

  -- during instruction fetch time slice
  ope_addr: in std_logic_vector(31 downto 0);
  ope_we: in std_logic;
  ope_ce: in std_logic;
  write_data: in std_logic_vector(31 downto 0);

  -- during memory time slice

  read_data: out std_logic_vector(31 downto 0);
  ready : out std_logic;      -- memory access is ready ready

  -- about exception
  -- 0001: ps2     0010: com1    0100: com2     1000: mmu extra
  serial_int : out std_logic_vector(3 downto 0);   -- interrupt, send to the exception module

  -- "000": no exception  "001":TLB modified  "010":TLBL  "011":TLBS  "100":ADEL  "101":ADES
  exc_code : out std_logic_vector(2 downto 0);    -- exception code
  bad_addr: out std_logic_vector(31 downto 0);
  -- about tlbwi
  -- index(69 downto 63) EntryHi(62 downto 44) EntryLo0(43 downto 24) DV(23 downto 22) EntryLo1(21 downto 2) DV(1 downto 0)
  tlb_write_struct : in std_logic_vector(TLB_WRITE_STRUCT_WIDTH-1 downto 0);
  tlb_write_enable : in std_logic;

  -- which kind of alignment? from IDecode
  -- "00" 4byte   "01" 2byte    "10" 1byte
  align_type : in std_logic_vector(1 downto 0);

  -- send to physical level
  -- the address passed down to physical level of memory
  -- RAM:"00" + "0" + address(20 downto 0)
  -- Flash:"01" + address(21 downto 0)
  -- Serial:"10" + "0000000000000000000000";
  to_physical_addr : out std_logic_vector(23 downto 0);
  to_physical_data : out std_logic_vector(31 downto 0);

  to_physical_read_enable : out std_logic;
  to_physical_write_enable : out std_logic;

  -- from physical level
  from_physical_data : in std_logic_vector(31 downto 0);
  from_physical_ready : in std_logic;
  from_physical_serial : in std_logic
);
end mmu;

architecture Behavioral of mmu is

  -- choose between instruction_addr and virtual_addr
  signal addr : std_logic_vector(31 downto 0);

  -- related to TLB
  -- EntryHi(62 downto 44) EntryLo0(43 downto 24) DV0(23 downto 22) EntryLo1(21 downto 2) DV1(1 downto 0)
  type tlb_mem_block is array(TLB_NUM_ENTRY-1 downto 0) of std_logic_vector(TLB_ENTRY_WIDTH-1 downto 0);
  signal tlb_mem : tlb_mem_block := (others => (others => '0'));
  -- a matrix (21*32) to store the temp value
  type tlb_low_temp_value_block is array(20 downto 0) of std_logic_vector(tlb_num_entry*2-1 downto 0);
  signal tlb_low_temp_value : tlb_low_temp_value_block;
  -- virtual_addr equal to which EntryHi
  signal tlb_which_equal : std_logic_vector(tlb_num_entry-1 downto 0);
  -- virtual_addr match which EntryLo
  signal tlb_which_low : std_logic_vector(tlb_num_entry*2-1 downto 0);
  -- result of tlb transfer : address(20 downto 1) and Dirty(0)
  signal tlb_lookup_result : std_logic_vector(20 downto 0);
  signal tlb_missing : std_logic;
  signal tlb_writable : std_logic;
  -- end of tlb signals


  signal not_use_mmu : std_logic;
  signal special_com1_status : std_logic := '0';

  -- physical address after TLB transform
  -- not the one that give to the physical level
  signal physical_addr : std_logic_vector(31 downto 0);

  -- related to serial port
    -- the value of (COM1 + 4)
  signal serial_status_reg : std_logic := '1';

  -- exception code
  signal no_exception_accur : std_logic := '1';

  -- to physical level registers
  signal to_physical_addr_reg : std_logic_vector(23 downto 0);
  signal to_physical_data_reg : std_logic_vector(31 downto 0);
  signal to_physical_read_enable_reg : std_logic := '0';
  signal to_physical_write_enable_reg : std_logic := '0';

begin

-- serial logic
  -- choose addr on posedge
  --process(clk, rst)
  --begin
  --      if rst = '0' then
  --          addr <= x"90000000";
  --  elsif clk'event and clk = '1' and from_physical_ready = '1' and ope_ce = '1'  then
  --    addr <= ope_addr;
  --  end if;
  --end process;

  addr <= ope_addr;


  -- handle TLBWI
  process(clk)
    variable tlb_index : integer range 127 downto 0 := 0;
  begin
    if clk'event and clk = '1' then
      if tlb_write_enable = '1' then
        tlb_index := conv_integer(tlb_write_struct(tlb_write_struct_width - 1 downto tlb_write_struct_width - tlb_index_width));
        tlb_mem(tlb_index) <= tlb_write_struct(tlb_write_struct_width - tlb_index_width - 1 downto 0);
      end if;
    end if;
  end process;

  -- handle exception
  process(align_type, ope_ce, addr, tlb_missing)
  begin
    if( (align_type = ALIGN_TYPE_HALF_WORD and addr(0) = '1') or (align_type = ALIGN_TYPE_WORD and addr(1 downto 0) /= "00") ) then
      if( ope_ce = '1' and ope_we = '0' )then
        exc_code <= ADE_L;
        bad_addr <= addr;
      elsif( ope_ce = '1' and ope_we = '1') then
        exc_code <= ADE_S;
        bad_addr <= addr;
      else
        exc_code <= (others => '0');
        bad_addr <= (others => '0');
      end if;
    -- tlb missing
    elsif tlb_missing = '1' then
      if( ope_ce = '1' and ope_we = '0' )then
        exc_code <= TLB_L;
        bad_addr <= addr;
      elsif( ope_ce = '1' and ope_we = '1' ) then
        exc_code <= TLB_S;
        bad_addr <= addr;
      else
        exc_code <= (others => '0');
        bad_addr <= (others => '0');
      end if;
    -- tlb modified
    elsif ( tlb_writable = '0') then
      if( ope_ce = '1' and ope_we = '1' ) then
        exc_code <= TLB_MODIFIED;
        bad_addr <= addr;
      else
        exc_code <= (others => '0');
        bad_addr <= (others => '0');
      end if;
    end if;
  end process;



  -- clear enable and data and addr on posedge
  -- send information to physical level on negedge
  to_physical_addr <= to_physical_addr_reg;
  to_physical_data <= to_physical_data_reg;
  to_physical_read_enable <= to_physical_read_enable_reg;
  to_physical_write_enable <= to_physical_write_enable_reg;

-- combination logic
  -- control signal
  not_use_mmu <= '1' when addr(31 downto 29) = "100" or addr(31 downto 29) = "101"
             else '0' ;

  special_com1_status <= '1'  when addr(31 downto 0) = VIRTUAL_SERIAL_STATUS
                  else '0';

  physical_addr <= "000" & addr(28 downto 0)
              when not_use_mmu = '1'
              else tlb_lookup_result(20 downto 1) & addr(11 downto 0)
               when not_use_mmu = '0' and tlb_missing = '0'
              else x"FFFFFFFF";

  no_exception_accur <= '1'
                  when (not((align_type = ALIGN_TYPE_HALF_WORD and addr(0) = '1') or (align_type = ALIGN_TYPE_WORD and addr(1 downto 0) /= "00")) )
                      and tlb_missing = '0' and tlb_writable = '1'
                 else '0';

  -- to physical_level
  to_physical_addr_reg <= "00" & physical_addr(23 downto 2) -- Flash
                    when physical_addr(31 downto 24) = x"1E"
                  else  "010" & physical_addr(22 downto 2)    -- RAM
                    when physical_addr(31 downto 23) = "000000000"
                  else "1000" & x"00000"              -- serial
                    when physical_addr(31 downto 0) = PHYSICAL_SERIAL_DATA
                  else "11" & x"000" & physical_addr(11 downto 2)
                    when physical_addr(31 downto 12) = x"10000"
                  else x"FFFFFF";

  to_physical_data_reg <= write_data;

  to_physical_read_enable_reg <= '1'
                      when( special_com1_status = '0' and no_exception_accur = '1' and from_physical_ready = '1' and ope_we = '0' and ope_ce = '1')
                    else '0';

  to_physical_write_enable_reg <= '1'
                      when( special_com1_status = '0' and no_exception_accur = '1' and from_physical_ready = '1' and ope_we = '1' and ope_ce = '1')
                    else '0';

  -- to top mem level
  read_data <= x"0000000" & "00" & serial_status_reg & "1"
          when (special_com1_status = '1')
          else from_physical_data;

  ready <= from_physical_ready;
  --serial_int <= from_physical_serial;
  serial_int <= "0000";

  -- register of serial status, return this directly if you load serial status
  serial_status_reg <= '1'
                when (from_physical_serial = '1')
                else '0';

  -- which EntryLo is selected and generate tlb_temp
  tlb_check : for i in tlb_num_entry-1 downto 0 generate
    tlb_which_equal(i) <= '1' when (tlb_mem(i)(62 downto 44) = addr(31 downto 13))
                  else '0';
    tlb_which_low(i*2) <= tlb_which_equal(i) and tlb_mem(i)(0) and ( addr(12));
    tlb_which_low(i*2+1) <= tlb_which_equal(i) and tlb_mem(i)(22) and ( not addr(12));

    tlb_temp : for j in 20 downto 0 generate
      tlb_low_temp_value(j)(i*2) <= tlb_which_low(i*2) and tlb_mem(i)(j+1);
      tlb_low_temp_value(j)(i*2+1) <= tlb_which_low(i*2+1) and tlb_mem(i)(j+23);
    end generate tlb_temp;
  end generate tlb_check;

  -- generate lookup result
  -- tlb_lookup_result can be generated with "or reduce" operator in Verilog, but in VHDL it is difficult
  tlb_result : for i in 20 downto 0 generate
    tlb_lookup_result(i) <= tlb_low_temp_value(i)(0) or
                            tlb_low_temp_value(i)(1) or
                            tlb_low_temp_value(i)(2) or
                            tlb_low_temp_value(i)(3) or
                            tlb_low_temp_value(i)(4) or
                            tlb_low_temp_value(i)(5) or
                            tlb_low_temp_value(i)(6) or
                            tlb_low_temp_value(i)(7) or
                            tlb_low_temp_value(i)(8) or
                            tlb_low_temp_value(i)(9) or
                            tlb_low_temp_value(i)(10) or
                            tlb_low_temp_value(i)(11) or
                            tlb_low_temp_value(i)(12) or
                            tlb_low_temp_value(i)(13) or
                            tlb_low_temp_value(i)(14) or
                            tlb_low_temp_value(i)(15) or
                            tlb_low_temp_value(i)(16) or
                            tlb_low_temp_value(i)(17) or
                            tlb_low_temp_value(i)(18) or
                            tlb_low_temp_value(i)(19) or
                            tlb_low_temp_value(i)(20) or
                            tlb_low_temp_value(i)(21) or
                            tlb_low_temp_value(i)(22) or
                            tlb_low_temp_value(i)(23) or
                            tlb_low_temp_value(i)(24) or
                            tlb_low_temp_value(i)(25) or
                            tlb_low_temp_value(i)(26) or
                            tlb_low_temp_value(i)(27) or
                            tlb_low_temp_value(i)(28) or
                            tlb_low_temp_value(i)(29) or
                            tlb_low_temp_value(i)(30) or
                            tlb_low_temp_value(i)(31) or
                            tlb_low_temp_value(i)(32) or
                            tlb_low_temp_value(i)(33) or
                            tlb_low_temp_value(i)(34) or
                            tlb_low_temp_value(i)(35) or
                            tlb_low_temp_value(i)(36) or
                            tlb_low_temp_value(i)(37) or
                            tlb_low_temp_value(i)(38) or
                            tlb_low_temp_value(i)(39) or
                            tlb_low_temp_value(i)(40) or
                            tlb_low_temp_value(i)(41) or
                            tlb_low_temp_value(i)(42) or
                            tlb_low_temp_value(i)(43) or
                            tlb_low_temp_value(i)(44) or
                            tlb_low_temp_value(i)(45) or
                            tlb_low_temp_value(i)(46) or
                            tlb_low_temp_value(i)(47) or
                            tlb_low_temp_value(i)(48) or
                            tlb_low_temp_value(i)(49) or
                            tlb_low_temp_value(i)(50) or
                            tlb_low_temp_value(i)(51) or
                            tlb_low_temp_value(i)(52) or
                            tlb_low_temp_value(i)(53) or
                            tlb_low_temp_value(i)(54) or
                            tlb_low_temp_value(i)(55) or
                            tlb_low_temp_value(i)(56) or
                            tlb_low_temp_value(i)(57) or
                            tlb_low_temp_value(i)(58) or
                            tlb_low_temp_value(i)(59) or
                            tlb_low_temp_value(i)(60) or
                            tlb_low_temp_value(i)(61) or
                            tlb_low_temp_value(i)(62) or
                            tlb_low_temp_value(i)(63) or
                            tlb_low_temp_value(i)(64) or
                            tlb_low_temp_value(i)(65) or
                            tlb_low_temp_value(i)(66) or
                            tlb_low_temp_value(i)(67) or
                            tlb_low_temp_value(i)(68) or
                            tlb_low_temp_value(i)(69) or
                            tlb_low_temp_value(i)(70) or
                            tlb_low_temp_value(i)(71) or
                            tlb_low_temp_value(i)(72) or
                            tlb_low_temp_value(i)(73) or
                            tlb_low_temp_value(i)(74) or
                            tlb_low_temp_value(i)(75) or
                            tlb_low_temp_value(i)(76) or
                            tlb_low_temp_value(i)(77) or
                            tlb_low_temp_value(i)(78) or
                            tlb_low_temp_value(i)(79) or
                            tlb_low_temp_value(i)(80) or
                            tlb_low_temp_value(i)(81) or
                            tlb_low_temp_value(i)(82) or
                            tlb_low_temp_value(i)(83) or
                            tlb_low_temp_value(i)(84) or
                            tlb_low_temp_value(i)(85) or
                            tlb_low_temp_value(i)(86) or
                            tlb_low_temp_value(i)(87) or
                            tlb_low_temp_value(i)(88) or
                            tlb_low_temp_value(i)(89) or
                            tlb_low_temp_value(i)(90) or
                            tlb_low_temp_value(i)(91) or
                            tlb_low_temp_value(i)(92) or
                            tlb_low_temp_value(i)(93) or
                            tlb_low_temp_value(i)(94) or
                            tlb_low_temp_value(i)(95) or
                            tlb_low_temp_value(i)(96) or
                            tlb_low_temp_value(i)(97) or
                            tlb_low_temp_value(i)(98) or
                            tlb_low_temp_value(i)(99) or
                            tlb_low_temp_value(i)(100) or
                            tlb_low_temp_value(i)(101) or
                            tlb_low_temp_value(i)(102) or
                            tlb_low_temp_value(i)(103) or
                            tlb_low_temp_value(i)(104) or
                            tlb_low_temp_value(i)(105) or
                            tlb_low_temp_value(i)(106) or
                            tlb_low_temp_value(i)(107) or
                            tlb_low_temp_value(i)(108) or
                            tlb_low_temp_value(i)(109) or
                            tlb_low_temp_value(i)(110) or
                            tlb_low_temp_value(i)(111) or
                            tlb_low_temp_value(i)(112) or
                            tlb_low_temp_value(i)(113) or
                            tlb_low_temp_value(i)(114) or
                            tlb_low_temp_value(i)(115) or
                            tlb_low_temp_value(i)(116) or
                            tlb_low_temp_value(i)(117) or
                            tlb_low_temp_value(i)(118) or
                            tlb_low_temp_value(i)(119) or
                            tlb_low_temp_value(i)(120) or
                            tlb_low_temp_value(i)(121) or
                            tlb_low_temp_value(i)(122) or
                            tlb_low_temp_value(i)(123) or
                            tlb_low_temp_value(i)(124) or
                            tlb_low_temp_value(i)(125) or
                            tlb_low_temp_value(i)(126) or
                            tlb_low_temp_value(i)(127) or
                            tlb_low_temp_value(i)(128) or
                            tlb_low_temp_value(i)(129) or
                            tlb_low_temp_value(i)(130) or
                            tlb_low_temp_value(i)(131) or
                            tlb_low_temp_value(i)(132) or
                            tlb_low_temp_value(i)(133) or
                            tlb_low_temp_value(i)(134) or
                            tlb_low_temp_value(i)(135) or
                            tlb_low_temp_value(i)(136) or
                            tlb_low_temp_value(i)(137) or
                            tlb_low_temp_value(i)(138) or
                            tlb_low_temp_value(i)(139) or
                            tlb_low_temp_value(i)(140) or
                            tlb_low_temp_value(i)(141) or
                            tlb_low_temp_value(i)(142) or
                            tlb_low_temp_value(i)(143) or
                            tlb_low_temp_value(i)(144) or
                            tlb_low_temp_value(i)(145) or
                            tlb_low_temp_value(i)(146) or
                            tlb_low_temp_value(i)(147) or
                            tlb_low_temp_value(i)(148) or
                            tlb_low_temp_value(i)(149) or
                            tlb_low_temp_value(i)(150) or
                            tlb_low_temp_value(i)(151) or
                            tlb_low_temp_value(i)(152) or
                            tlb_low_temp_value(i)(153) or
                            tlb_low_temp_value(i)(154) or
                            tlb_low_temp_value(i)(155) or
                            tlb_low_temp_value(i)(156) or
                            tlb_low_temp_value(i)(157) or
                            tlb_low_temp_value(i)(158) or
                            tlb_low_temp_value(i)(159) or
                            tlb_low_temp_value(i)(160) or
                            tlb_low_temp_value(i)(161) or
                            tlb_low_temp_value(i)(162) or
                            tlb_low_temp_value(i)(163) or
                            tlb_low_temp_value(i)(164) or
                            tlb_low_temp_value(i)(165) or
                            tlb_low_temp_value(i)(166) or
                            tlb_low_temp_value(i)(167) or
                            tlb_low_temp_value(i)(168) or
                            tlb_low_temp_value(i)(169) or
                            tlb_low_temp_value(i)(170) or
                            tlb_low_temp_value(i)(171) or
                            tlb_low_temp_value(i)(172) or
                            tlb_low_temp_value(i)(173) or
                            tlb_low_temp_value(i)(174) or
                            tlb_low_temp_value(i)(175) or
                            tlb_low_temp_value(i)(176) or
                            tlb_low_temp_value(i)(177) or
                            tlb_low_temp_value(i)(178) or
                            tlb_low_temp_value(i)(179) or
                            tlb_low_temp_value(i)(180) or
                            tlb_low_temp_value(i)(181) or
                            tlb_low_temp_value(i)(182) or
                            tlb_low_temp_value(i)(183) or
                            tlb_low_temp_value(i)(184) or
                            tlb_low_temp_value(i)(185) or
                            tlb_low_temp_value(i)(186) or
                            tlb_low_temp_value(i)(187) or
                            tlb_low_temp_value(i)(188) or
                            tlb_low_temp_value(i)(189) or
                            tlb_low_temp_value(i)(190) or
                            tlb_low_temp_value(i)(191) or
                            tlb_low_temp_value(i)(192) or
                            tlb_low_temp_value(i)(193) or
                            tlb_low_temp_value(i)(194) or
                            tlb_low_temp_value(i)(195) or
                            tlb_low_temp_value(i)(196) or
                            tlb_low_temp_value(i)(197) or
                            tlb_low_temp_value(i)(198) or
                            tlb_low_temp_value(i)(199) or
                            tlb_low_temp_value(i)(200) or
                            tlb_low_temp_value(i)(201) or
                            tlb_low_temp_value(i)(202) or
                            tlb_low_temp_value(i)(203) or
                            tlb_low_temp_value(i)(204) or
                            tlb_low_temp_value(i)(205) or
                            tlb_low_temp_value(i)(206) or
                            tlb_low_temp_value(i)(207) or
                            tlb_low_temp_value(i)(208) or
                            tlb_low_temp_value(i)(209) or
                            tlb_low_temp_value(i)(210) or
                            tlb_low_temp_value(i)(211) or
                            tlb_low_temp_value(i)(212) or
                            tlb_low_temp_value(i)(213) or
                            tlb_low_temp_value(i)(214) or
                            tlb_low_temp_value(i)(215) or
                            tlb_low_temp_value(i)(216) or
                            tlb_low_temp_value(i)(217) or
                            tlb_low_temp_value(i)(218) or
                            tlb_low_temp_value(i)(219) or
                            tlb_low_temp_value(i)(220) or
                            tlb_low_temp_value(i)(221) or
                            tlb_low_temp_value(i)(222) or
                            tlb_low_temp_value(i)(223) or
                            tlb_low_temp_value(i)(224) or
                            tlb_low_temp_value(i)(225) or
                            tlb_low_temp_value(i)(226) or
                            tlb_low_temp_value(i)(227) or
                            tlb_low_temp_value(i)(228) or
                            tlb_low_temp_value(i)(229) or
                            tlb_low_temp_value(i)(230) or
                            tlb_low_temp_value(i)(231) or
                            tlb_low_temp_value(i)(232) or
                            tlb_low_temp_value(i)(233) or
                            tlb_low_temp_value(i)(234) or
                            tlb_low_temp_value(i)(235) or
                            tlb_low_temp_value(i)(236) or
                            tlb_low_temp_value(i)(237) or
                            tlb_low_temp_value(i)(238) or
                            tlb_low_temp_value(i)(239) or
                            tlb_low_temp_value(i)(240) or
                            tlb_low_temp_value(i)(241) or
                            tlb_low_temp_value(i)(242) or
                            tlb_low_temp_value(i)(243) or
                            tlb_low_temp_value(i)(244) or
                            tlb_low_temp_value(i)(245) or
                            tlb_low_temp_value(i)(246) or
                            tlb_low_temp_value(i)(247) or
                            tlb_low_temp_value(i)(248) or
                            tlb_low_temp_value(i)(249) or
                            tlb_low_temp_value(i)(250) or
                            tlb_low_temp_value(i)(251) or
                            tlb_low_temp_value(i)(252) or
                            tlb_low_temp_value(i)(253) or
                            tlb_low_temp_value(i)(254) or
                            tlb_low_temp_value(i)(255);
  end generate tlb_result;

  tlb_missing <= not(
                      not_use_mmu or
                      tlb_which_low(0) or
                      tlb_which_low(1) or
                      tlb_which_low(2) or
                      tlb_which_low(3) or
                      tlb_which_low(4) or
                      tlb_which_low(5) or
                      tlb_which_low(6) or
                      tlb_which_low(7) or
                      tlb_which_low(8) or
                      tlb_which_low(9) or
                      tlb_which_low(10) or
                      tlb_which_low(11) or
                      tlb_which_low(12) or
                      tlb_which_low(13) or
                      tlb_which_low(14) or
                      tlb_which_low(15) or
                      tlb_which_low(16) or
                      tlb_which_low(17) or
                      tlb_which_low(18) or
                      tlb_which_low(19) or
                      tlb_which_low(20) or
                      tlb_which_low(21) or
                      tlb_which_low(22) or
                      tlb_which_low(23) or
                      tlb_which_low(24) or
                      tlb_which_low(25) or
                      tlb_which_low(26) or
                      tlb_which_low(27) or
                      tlb_which_low(28) or
                      tlb_which_low(29) or
                      tlb_which_low(30) or
                      tlb_which_low(31) or
                      tlb_which_low(32) or
                      tlb_which_low(33) or
                      tlb_which_low(34) or
                      tlb_which_low(35) or
                      tlb_which_low(36) or
                      tlb_which_low(37) or
                      tlb_which_low(38) or
                      tlb_which_low(39) or
                      tlb_which_low(40) or
                      tlb_which_low(41) or
                      tlb_which_low(42) or
                      tlb_which_low(43) or
                      tlb_which_low(44) or
                      tlb_which_low(45) or
                      tlb_which_low(46) or
                      tlb_which_low(47) or
                      tlb_which_low(48) or
                      tlb_which_low(49) or
                      tlb_which_low(50) or
                      tlb_which_low(51) or
                      tlb_which_low(52) or
                      tlb_which_low(53) or
                      tlb_which_low(54) or
                      tlb_which_low(55) or
                      tlb_which_low(56) or
                      tlb_which_low(57) or
                      tlb_which_low(58) or
                      tlb_which_low(59) or
                      tlb_which_low(60) or
                      tlb_which_low(61) or
                      tlb_which_low(62) or
                      tlb_which_low(63) or
                      tlb_which_low(64) or
                      tlb_which_low(65) or
                      tlb_which_low(66) or
                      tlb_which_low(67) or
                      tlb_which_low(68) or
                      tlb_which_low(69) or
                      tlb_which_low(70) or
                      tlb_which_low(71) or
                      tlb_which_low(72) or
                      tlb_which_low(73) or
                      tlb_which_low(74) or
                      tlb_which_low(75) or
                      tlb_which_low(76) or
                      tlb_which_low(77) or
                      tlb_which_low(78) or
                      tlb_which_low(79) or
                      tlb_which_low(80) or
                      tlb_which_low(81) or
                      tlb_which_low(82) or
                      tlb_which_low(83) or
                      tlb_which_low(84) or
                      tlb_which_low(85) or
                      tlb_which_low(86) or
                      tlb_which_low(87) or
                      tlb_which_low(88) or
                      tlb_which_low(89) or
                      tlb_which_low(90) or
                      tlb_which_low(91) or
                      tlb_which_low(92) or
                      tlb_which_low(93) or
                      tlb_which_low(94) or
                      tlb_which_low(95) or
                      tlb_which_low(96) or
                      tlb_which_low(97) or
                      tlb_which_low(98) or
                      tlb_which_low(99) or
                      tlb_which_low(100) or
                      tlb_which_low(101) or
                      tlb_which_low(102) or
                      tlb_which_low(103) or
                      tlb_which_low(104) or
                      tlb_which_low(105) or
                      tlb_which_low(106) or
                      tlb_which_low(107) or
                      tlb_which_low(108) or
                      tlb_which_low(109) or
                      tlb_which_low(110) or
                      tlb_which_low(111) or
                      tlb_which_low(112) or
                      tlb_which_low(113) or
                      tlb_which_low(114) or
                      tlb_which_low(115) or
                      tlb_which_low(116) or
                      tlb_which_low(117) or
                      tlb_which_low(118) or
                      tlb_which_low(119) or
                      tlb_which_low(120) or
                      tlb_which_low(121) or
                      tlb_which_low(122) or
                      tlb_which_low(123) or
                      tlb_which_low(124) or
                      tlb_which_low(125) or
                      tlb_which_low(126) or
                      tlb_which_low(127) or
                      tlb_which_low(128) or
                      tlb_which_low(129) or
                      tlb_which_low(130) or
                      tlb_which_low(131) or
                      tlb_which_low(132) or
                      tlb_which_low(133) or
                      tlb_which_low(134) or
                      tlb_which_low(135) or
                      tlb_which_low(136) or
                      tlb_which_low(137) or
                      tlb_which_low(138) or
                      tlb_which_low(139) or
                      tlb_which_low(140) or
                      tlb_which_low(141) or
                      tlb_which_low(142) or
                      tlb_which_low(143) or
                      tlb_which_low(144) or
                      tlb_which_low(145) or
                      tlb_which_low(146) or
                      tlb_which_low(147) or
                      tlb_which_low(148) or
                      tlb_which_low(149) or
                      tlb_which_low(150) or
                      tlb_which_low(151) or
                      tlb_which_low(152) or
                      tlb_which_low(153) or
                      tlb_which_low(154) or
                      tlb_which_low(155) or
                      tlb_which_low(156) or
                      tlb_which_low(157) or
                      tlb_which_low(158) or
                      tlb_which_low(159) or
                      tlb_which_low(160) or
                      tlb_which_low(161) or
                      tlb_which_low(162) or
                      tlb_which_low(163) or
                      tlb_which_low(164) or
                      tlb_which_low(165) or
                      tlb_which_low(166) or
                      tlb_which_low(167) or
                      tlb_which_low(168) or
                      tlb_which_low(169) or
                      tlb_which_low(170) or
                      tlb_which_low(171) or
                      tlb_which_low(172) or
                      tlb_which_low(173) or
                      tlb_which_low(174) or
                      tlb_which_low(175) or
                      tlb_which_low(176) or
                      tlb_which_low(177) or
                      tlb_which_low(178) or
                      tlb_which_low(179) or
                      tlb_which_low(180) or
                      tlb_which_low(181) or
                      tlb_which_low(182) or
                      tlb_which_low(183) or
                      tlb_which_low(184) or
                      tlb_which_low(185) or
                      tlb_which_low(186) or
                      tlb_which_low(187) or
                      tlb_which_low(188) or
                      tlb_which_low(189) or
                      tlb_which_low(190) or
                      tlb_which_low(191) or
                      tlb_which_low(192) or
                      tlb_which_low(193) or
                      tlb_which_low(194) or
                      tlb_which_low(195) or
                      tlb_which_low(196) or
                      tlb_which_low(197) or
                      tlb_which_low(198) or
                      tlb_which_low(199) or
                      tlb_which_low(200) or
                      tlb_which_low(201) or
                      tlb_which_low(202) or
                      tlb_which_low(203) or
                      tlb_which_low(204) or
                      tlb_which_low(205) or
                      tlb_which_low(206) or
                      tlb_which_low(207) or
                      tlb_which_low(208) or
                      tlb_which_low(209) or
                      tlb_which_low(210) or
                      tlb_which_low(211) or
                      tlb_which_low(212) or
                      tlb_which_low(213) or
                      tlb_which_low(214) or
                      tlb_which_low(215) or
                      tlb_which_low(216) or
                      tlb_which_low(217) or
                      tlb_which_low(218) or
                      tlb_which_low(219) or
                      tlb_which_low(220) or
                      tlb_which_low(221) or
                      tlb_which_low(222) or
                      tlb_which_low(223) or
                      tlb_which_low(224) or
                      tlb_which_low(225) or
                      tlb_which_low(226) or
                      tlb_which_low(227) or
                      tlb_which_low(228) or
                      tlb_which_low(229) or
                      tlb_which_low(230) or
                      tlb_which_low(231) or
                      tlb_which_low(232) or
                      tlb_which_low(233) or
                      tlb_which_low(234) or
                      tlb_which_low(235) or
                      tlb_which_low(236) or
                      tlb_which_low(237) or
                      tlb_which_low(238) or
                      tlb_which_low(239) or
                      tlb_which_low(240) or
                      tlb_which_low(241) or
                      tlb_which_low(242) or
                      tlb_which_low(243) or
                      tlb_which_low(244) or
                      tlb_which_low(245) or
                      tlb_which_low(246) or
                      tlb_which_low(247) or
                      tlb_which_low(248) or
                      tlb_which_low(249) or
                      tlb_which_low(250) or
                      tlb_which_low(251) or
                      tlb_which_low(252) or
                      tlb_which_low(253) or
                      tlb_which_low(254) or
                      tlb_which_low(255)
              );
  tlb_writable <= not_use_mmu or tlb_lookup_result(0);

end architecture;
