LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
use work.CPU32.all;

ENTITY openmips is
  port(
    rst: in STD_LOGIC;
    clk: in STD_LOGIC;

    to_physical_addr : out std_logic_vector(23 downto 0);
    to_physical_data : out std_logic_vector(31 downto 0);

    to_physical_read_enable : out std_logic;
    to_physical_write_enable : out std_logic;

    from_physical_data : in std_logic_vector(31 downto 0);
    from_physical_ready : in std_logic;
    from_physical_serial : in std_logic

    );
end openmips;

architecture arch of openmips is

  component clock
  port(
    rst: in STD_LOGIC;
    clk: in STD_LOGIC;
    clk_new: BUFFER STD_LOGIC
    );
  end component;


  component pc_reg
  port(
    clk: in STD_LOGIC;
    rst: in STD_LOGIC;
    stall: in STD_LOGIC_VECTOR(5 downto 0);
    branch_flag_i: in STD_LOGIC;
    branch_target_address_i: in STD_LOGIC_VECTOR(31 downto 0);
    pc: buffer STD_LOGIC_VECTOR(31 downto 0);
    ce: buffer STD_LOGIC;

    -- exception
    flush: in STD_LOGIC;
    new_pc: in STD_LOGIC_VECTOR(31 downto 0)
    );
  end component;

  component if_id
  port(
    clk:in STD_LOGIC;
    rst:in STD_LOGIC;
    if_pc:in STD_LOGIC_VECTOR(31 downto 0);
    if_inst:in STD_LOGIC_VECTOR(31 downto 0);
    stall: in STD_LOGIC_VECTOR(5 downto 0);
    id_pc:out STD_LOGIC_VECTOR(31 downto 0);
    id_inst:out STD_LOGIC_VECTOR(31 downto 0);

    --exception
    flush: in STD_LOGIC
    );
  end component;

  component id
  port(
    rst:in STD_LOGIC;
    pc_i:in STD_LOGIC_VECTOR(31 downto 0);  -- Program counter
    inst_i:in STD_LOGIC_VECTOR(31 downto 0);  -- Instruction
    reg1_data_i:in STD_LOGIC_VECTOR(31 downto 0); -- Result from register
    reg2_data_i:in STD_LOGIC_VECTOR(31 downto 0); -- Result from register
    reg1_read_o:buffer STD_LOGIC;  -- Control register reading
    reg2_read_o:buffer STD_LOGIC;  -- Control register reading
    reg1_addr_o:buffer STD_LOGIC_VECTOR(4 downto 0); --size = 5 Register address
    reg2_addr_o:buffer STD_LOGIC_VECTOR(4 downto 0); --size = 5 Register address
    ex_wreg_i:in STD_LOGIC; -- Data forwarding
    ex_wdata_i:in STD_LOGIC_VECTOR(31 downto 0); -- Data forwarding
    ex_wd_i:in STD_LOGIC_VECTOR(4 downto 0);  --size = 5 Data forwarding
    mem_wreg_i:in STD_LOGIC; -- Data forwarding
    mem_wdata_i:in STD_LOGIC_VECTOR(31 downto 0); -- Data forwarding
    mem_wd_i:in STD_LOGIC_VECTOR(4 downto 0); --size = 5 Data forwarding
    aluop_o:out STD_LOGIC_VECTOR(7 downto 0); --size = 8
    alusel_o:out STD_LOGIC_VECTOR(2 downto 0);  --size = 3
    reg1_o:buffer STD_LOGIC_VECTOR(31 downto 0); -- Operand 1
    reg2_o:buffer STD_LOGIC_VECTOR(31 downto 0); -- Operand 2
    wd_o:out STD_LOGIC_VECTOR(4 downto 0);  --size = 5 Write-Destination (register)
    wreg_o:out STD_LOGIC; -- =1 -> need to write reg
    is_in_delayslot_i:in STD_LOGIC;
    next_inst_in_delayslot_o:out STD_LOGIC;
    branch_flag_o:out STD_LOGIC;
    branch_target_address_o:out STD_LOGIC_VECTOR(31 downto 0);
    link_addr_o:out STD_LOGIC_VECTOR(31 downto 0);
    is_in_delayslot_o:out STD_LOGIC;
    inst_o:out STD_LOGIC_VECTOR(31 downto 0);
    stallreq:out STD_LOGIC; -- =1 -> stall pipeline
    ex_aluop_i:in STD_LOGIC_VECTOR(7 downto 0);

    -- exception
    excepttype_o:out STD_LOGIC_VECTOR(31 downto 0);
    current_inst_addr_o: out STD_LOGIC_VECTOR(31 downto 0)
    );
  end component;

  component regfile
  port(
    rst: in STD_LOGIC;
    clk: in STD_LOGIC;

    we: in STD_LOGIC;
    waddr: in STD_LOGIC_VECTOR(4 downto 0);
    wdata: in STD_LOGIC_VECTOR(31 downto 0);

    re1: in STD_LOGIC;
    raddr1: in STD_LOGIC_VECTOR(4 downto 0);
    rdata1: out STD_LOGIC_VECTOR(31 downto 0);
    re2: in STD_LOGIC;
    raddr2: in STD_LOGIC_VECTOR(4 downto 0);
    rdata2: out STD_LOGIC_VECTOR(31 downto 0)
    );
  end component;

  component hilo_reg
  port(
    clk:in STD_LOGIC;
    rst:in STD_LOGIC;
    we:in STD_LOGIC;
    hi_i:in STD_LOGIC_VECTOR(31 downto 0);
    lo_i:in STD_LOGIC_VECTOR(31 downto 0);
    hi_o:out STD_LOGIC_VECTOR(31 downto 0);
    lo_o:out STD_LOGIC_VECTOR(31 downto 0)
    );
  end component;

  component id_ex
  port(
    clk: IN STD_LOGIC;
    rst: IN STD_LOGIC;
    id_aluop: IN STD_LOGIC_VECTOR (7 downto 0);
    id_alusel: IN STD_LOGIC_VECTOR (2 downto 0);
    id_reg1: IN STD_LOGIC_VECTOR (31 downto 0);
    id_reg2: IN STD_LOGIC_VECTOR (31 downto 0);
    id_wd: IN STD_LOGIC_VECTOR (4 downto 0);
    id_wreg: IN STD_LOGIC;
    stall: IN STD_LOGIC_VECTOR(5 downto 0);

    id_link_address: IN STD_LOGIC_VECTOR(31 downto 0);
    id_is_in_delayslot: IN STD_LOGIC;
    next_inst_in_delayslot_i: IN STD_LOGIC;

    id_inst:in STD_LOGIC_VECTOR(31 downto 0);
    ex_inst:out STD_LOGIC_VECTOR(31 downto 0);

    ex_aluop: OUT STD_LOGIC_VECTOR (7 downto 0);
    ex_alusel: OUT STD_LOGIC_VECTOR (2 downto 0);
    ex_reg1: OUT STD_LOGIC_VECTOR (31 downto 0);
    ex_reg2: OUT STD_LOGIC_VECTOR (31 downto 0);
    ex_wd: OUT STD_LOGIC_VECTOR (4 downto 0);
    ex_wreg: OUT STD_LOGIC;

    ex_link_address: OUT STD_LOGIC_VECTOR(31 downto 0);
    ex_is_in_delayslot: OUT STD_LOGIC;
    is_in_delayslot_o: OUT STD_LOGIC;

    -- exception
    flush: IN STD_LOGIC;
    id_excepttype: IN STD_LOGIC_VECTOR(31 downto 0);
    id_current_inst_addr: IN STD_LOGIC_VECTOR(31 downto 0);

    ex_excepttype: OUT STD_LOGIC_VECTOR(31 downto 0);
    ex_current_inst_addr: OUT STD_LOGIC_VECTOR(31 downto 0)

    );
  end component;

  component ex
  port (
    rst: IN STD_LOGIC;

    aluop_i: IN STD_LOGIC_VECTOR(7 downto 0);
    alusel_i: IN STD_LOGIC_VECTOR(2 downto 0);
    reg1_i: IN STD_LOGIC_VECTOR(31 downto 0);
    reg2_i: IN STD_LOGIC_VECTOR(31 downto 0);
    wd_i: IN STD_LOGIC_VECTOR(4 downto 0);
    wreg_i: IN STD_LOGIC;

    hi_i: IN STD_LOGIC_VECTOR(31 downto 0);
    lo_i: IN STD_LOGIC_VECTOR(31 downto 0);

    wb_hi_i: IN STD_LOGIC_VECTOR(31 downto 0);
    wb_lo_i: IN STD_LOGIC_VECTOR(31 downto 0);
    wb_whilo_i: IN STD_LOGIC;
    wb_cp0_reg_we: IN STD_LOGIC;
    wb_cp0_reg_write_addr: IN STD_LOGIC_VECTOR(4 downto 0);
    wb_cp0_reg_data: IN STD_LOGIC_VECTOR(31 downto 0);

    mem_hi_i: IN STD_LOGIC_VECTOR(31 downto 0);
    mem_lo_i: IN STD_LOGIC_VECTOR(31 downto 0);
    mem_whilo_i: IN STD_LOGIC;
    mem_cp0_reg_we: IN STD_LOGIC;
    mem_cp0_reg_write_addr: IN STD_LOGIC_VECTOR(4 downto 0);
    mem_cp0_reg_data: IN STD_LOGIC_VECTOR(31 downto 0);

    link_address_i: IN STD_LOGIC_VECTOR(31 downto 0);
    is_in_delayslot_i: IN STD_LOGIC;

    inst_i: IN STD_LOGIC_VECTOR(31 downto 0);

    cp0_reg_data_i: IN STD_LOGIC_VECTOR(31 downto 0);

    excepttype_i: IN STD_LOGIC_VECTOR(31 downto 0);
    current_inst_addr_i: IN STD_LOGIC_VECTOR(31 downto 9);

    stallreq: OUT STD_LOGIC;
    hi_o: OUT STD_LOGIC_VECTOR(31 downto 0);
    lo_o: OUT STD_LOGIC_VECTOR(31 downto 0);
    whilo_o: OUT STD_LOGIC;

    wd_o: OUT STD_LOGIC_VECTOR(4 downto 0);
    wreg_o: OUT STD_LOGIC;
    wdata_o: OUT STD_LOGIC_VECTOR(31 downto 0);

    aluop_o: OUT STD_LOGIC_VECTOR(7 downto 0);
    mem_addr_o: OUT STD_LOGIC_VECTOR(31 downto 0);
    reg2_o: OUT STD_LOGIC_VECTOR(31 downto 0);

    cp0_reg_read_addr_o: OUT STD_LOGIC_VECTOR(4 downto 0);
    cp0_reg_we_o: OUT STD_LOGIC;
    cp0_reg_write_addr_o: OUT STD_LOGIC_VECTOR(4 downto 0);
    cp0_reg_data_o: OUT STD_LOGIC_VECTOR(31 downto 0);

    excepttype_o: OUT STD_LOGIC_VECTOR(31 downto 0);
    current_inst_addr_o: OUT STD_LOGIC_VECTOR(31 downto 0);
    is_in_delayslot_o: OUT STD_LOGIC
    );
  end component;

  component ex_mem
  port (
    clk: IN STD_LOGIC;
    rst: IN STD_LOGIC;

    ex_wd: IN STD_LOGIC_VECTOR (4 downto 0);
    ex_wreg: IN STD_LOGIC;
    ex_wdata: IN STD_LOGIC_VECTOR (31 downto 0);
    ex_hi: IN STD_LOGIC_VECTOR (31 downto 0);
    ex_lo: IN STD_LOGIC_VECTOR (31 downto 0);
    ex_whilo: IN STD_LOGIC;
    ex_aluop: IN STD_LOGIC_VECTOR (7 downto 0);
    ex_mem_addr: IN STD_LOGIC_VECTOR (31 downto 0);
    ex_reg2: IN STD_LOGIC_VECTOR (31 downto 0);
    ex_cp0_reg_we: IN STD_LOGIC;
    ex_cp0_reg_write_addr: IN STD_LOGIC_VECTOR (4 downto 0);
    ex_cp0_reg_data: IN STD_LOGIC_VECTOR (31 downto 0);
    stall: IN STD_LOGIC_VECTOR(5 downto 0);

    mem_wd: BUFFER STD_LOGIC_VECTOR (4 downto 0);
    mem_wreg: BUFFER STD_LOGIC;
    mem_wdata: BUFFER STD_LOGIC_VECTOR (31 downto 0);
    mem_hi: OUT STD_LOGIC_VECTOR (31 downto 0);
    mem_lo: OUT STD_LOGIC_VECTOR (31 downto 0);
    mem_whilo: OUT STD_LOGIC;
    mem_aluop: OUT STD_LOGIC_VECTOR (7 downto 0);
    mem_mem_addr: OUT STD_LOGIC_VECTOR (31 downto 0);
    mem_reg2: OUT STD_LOGIC_VECTOR (31 downto 0);
    mem_cp0_reg_we: OUT STD_LOGIC;
    mem_cp0_reg_write_addr: OUT STD_LOGIC_VECTOR (4 downto 0);
    mem_cp0_reg_data: OUT STD_LOGIC_VECTOR (31 downto 0);

    -- exception
    flush: IN STD_LOGIC;
    ex_excepttype: IN STD_LOGIC_VECTOR(31 downto 0);
    ex_current_inst_addr: IN STD_LOGIC_VECTOR(31 downto 0);
    ex_is_in_delayslot: IN STD_LOGIC;

    mem_excepttype: OUT STD_LOGIC_VECTOR(31 downto 0);
    mem_current_inst_addr: OUT STD_LOGIC_VECTOR(31 downto 0);
    mem_is_in_delayslot: OUT STD_LOGIC

    );
  end component;

  component mem
  port (
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
  end component;

  component mem_wb
  port (
    rst: in STD_LOGIC;
    clk: in STD_LOGIC;
    -- input
    mem_wd: in STD_LOGIC_VECTOR(4 downto 0);
    mem_wreg: in STD_LOGIC;
    mem_wdata: in STD_LOGIC_VECTOR(31 downto 0);
    mem_hi: in STD_LOGIC_VECTOR(31 downto 0);
    mem_lo: in STD_LOGIC_VECTOR(31 downto 0);
    mem_whilo: in STD_LOGIC;
    mem_cp0_reg_we: in STD_LOGIC;
    mem_cp0_reg_write_addr: in STD_LOGIC_VECTOR(4 downto 0);
    mem_cp0_reg_data: in STD_LOGIC_VECTOR(31 downto 0);
    stall: in STD_LOGIC_VECTOR(5 downto 0);
    flush: in std_logic;

    -- output
    wb_wd: out STD_LOGIC_VECTOR(4 downto 0);
    wb_wreg: out STD_LOGIC;
    wb_wdata: out STD_LOGIC_VECTOR(31 downto 0);
    wb_hi: out STD_LOGIC_VECTOR(31 downto 0);
    wb_lo: out STD_LOGIC_VECTOR(31 downto 0);
    wb_whilo: out STD_LOGIC;
    wb_cp0_reg_we: out STD_LOGIC;
    wb_cp0_reg_write_addr: out STD_LOGIC_VECTOR(4 downto 0);
    wb_cp0_reg_data: out STD_LOGIC_VECTOR(31 downto 0)
    );
  end component;

  component ctrl
  port (
    rst: IN STD_LOGIC;
    stallreq_from_id: IN STD_LOGIC;
    stallreq_from_ex: IN STD_LOGIC;
    stallreq_from_mem: IN STD_LOGIC;
    excepttype_i: IN STD_LOGIC_VECTOR(31 downto 0);
    cp0_epc_i: IN STD_LOGIC_VECTOR(31 downto 0);
    new_pc: OUT STD_LOGIC_VECTOR(31 downto 0);
    flush: OUT STD_LOGIC;
    stall: OUT STD_LOGIC_VECTOR(5 downto 0)
    );
  end component;

  component memcontrol
  port (
    --up
    rst: in STD_LOGIC;
    clk: in STD_LOGIC;
    inst_data_i: out STD_LOGIC_VECTOR(31 downto 0);
    inst_addr_o: in STD_LOGIC_VECTOR(31 downto 0);
    inst_ce_o: out STD_LOGIC;

    ram_data_i: out STD_LOGIC_VECTOR(31 downto 0);
    ram_addr_o: in STD_LOGIC_VECTOR(31 downto 0);
    ram_data_o: in STD_LOGIC_VECTOR(31 downto 0);
    ram_we_o: in STD_LOGIC;
    ram_align: in STD_LOGIC_VECTOR(1 downto 0);
    ram_ce_o: in STD_LOGIC;

    --mix
    stallreq: out STD_LOGIC;

    --down
    ope_addr: out std_logic_vector(31 downto 0);
    write_data: out std_logic_vector(31 downto 0);
    read_data: in std_logic_vector(31 downto 0);
    data_ready: in std_logic;
    ope_we: out std_logic;
    ope_ce: out std_logic;
    align_type: out std_logic_vector(1 downto 0)
    );
  end component;

  component mmu
  port (
    clk : in std_logic;
    rst : in std_logic;

    ope_addr: in std_logic_vector(31 downto 0);
    ope_we: in std_logic;
    ope_ce: in std_logic;
    write_data: in std_logic_vector(31 downto 0);

    read_data: out std_logic_vector(31 downto 0);
    ready : out std_logic;

    -- about exception
    serial_int : out std_logic_vector(3 downto 0);
    exc_code : out std_logic_vector(2 downto 0);
    bad_addr: out std_logic_vector(31 downto 0);

    tlb_write_struct : in std_logic_vector(TLB_WRITE_STRUCT_WIDTH-1 downto 0);
    tlb_write_enable : in std_logic;

    --

    align_type : in std_logic_vector(1 downto 0);

    to_physical_addr : out std_logic_vector(23 downto 0);
    to_physical_data : out std_logic_vector(31 downto 0);

    to_physical_read_enable : out std_logic;
    to_physical_write_enable : out std_logic;

    -- from physical level
    from_physical_data : in std_logic_vector(31 downto 0);
    from_physical_ready : in std_logic;
    from_physical_serial : in std_logic
    );
  end component;

  component cp0_reg
  port (
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

    BadVAddr_o : out std_logic_vector(31 downto 0);
    Count_o : out std_logic_vector(31 downto 0);
    Compare_o : out std_logic_vector(31 downto 0);

    EBase_o : out std_logic_vector(31 downto 0);
    timer_int_o : out std_logic;

    excepttype_i: in STD_LOGIC_VECTOR(31 downto 0);
    current_inst_address_i: in STD_LOGIC_VECTOR(31 downto 0);
    badAddr_i: in STD_LOGIC_VECTOR(31 downto 0);
    is_in_delayslot_i: in STD_LOGIC
    );
  end component;

-- about memcontrol -- CPU
  signal inst_data: STD_LOGIC_VECTOR(31 downto 0);
  signal inst_addr: STD_LOGIC_VECTOR(31 downto 0);
  signal inst_ce: STD_LOGIC;

  signal ram_data_i: STD_LOGIC_VECTOR(31 downto 0);
  signal ram_addr_o: STD_LOGIC_VECTOR(31 downto 0);
  signal ram_data_o: STD_LOGIC_VECTOR(31 downto 0);
  signal ram_we_o: STD_LOGIC;
  signal ram_align: STD_LOGIC_VECTOR(3 downto 0);
  signal ram_ce_o: STD_LOGIC;

-- about memcontrol -- mmu
  signal ope_data: STD_LOGIC_VECTOR(31 downto 0);
  signal ope_addr: STD_LOGIC_VECTOR(31 downto 0);
  signal ope_ce: STD_LOGIC;
  signal ope_we: STD_LOGIC;
  signal mmu_result_data: STD_LOGIC_VECTOR(31 downto 0);
  signal data_ready: STD_LOGIC;
  signal align_type: STD_LOGIC_VECTOR(1 downto 0);

-- mmu -- Exception
  signal serial_int_mmu: STD_LOGIC_VECTOR(3 downto 0);
  signal exc_code_mmu: STD_LOGIC_VECTOR(2 downto 0);
  signal bad_addr_mmu: STD_LOGIC_VECTOR(31 downto 0);
  signal tlb_write_struct: STD_LOGIC_VECTOR(TLB_WRITE_STRUCT_WIDTH-1 downto 0);
  signal tlb_write_enable: STD_LOGIC;

-- cp0

  signal Index : std_logic_vector(31 downto 0);
  signal EntryLo0 : std_logic_vector(31 downto 0);
  signal EntryLo1 : std_logic_vector(31 downto 0);
  signal PageMask : std_logic_vector(31 downto 0);
  signal EntryHi : std_logic_vector(31 downto 0);

  signal BadVAddr : std_logic_vector(31 downto 0);
  signal Count : std_logic_vector(31 downto 0);
  signal Compare : std_logic_vector(31 downto 0);

  signal EBase : std_logic_vector(31 downto 0);
  signal timer_int : std_logic;


-- clock
  signal clk_new: STD_LOGIC := '0';

-- ctrl
  signal stall: STD_LOGIC_VECTOR(5 downto 0);
  signal stallreq_from_ex: STD_LOGIC;
  signal stallreq_from_id: STD_LOGIC;
  signal stallreq_from_mem: STD_LOGIC;
  signal new_pc: STD_LOGIC_VECTOR(31 downto 0);
  signal flush: STD_LOGIC;


-- branch
-- ID to PC
  signal branch_target_address: STD_LOGIC_VECTOR(31 downto 0);
  signal branch_flag: STD_LOGIC;
-- ID to ID/EX
  signal id_is_in_delayslot: STD_LOGIC;
  signal id_link_address: STD_LOGIC_VECTOR(31 downto 0);
  signal next_inst_in_delayslot: STD_LOGIC;
-- ID/EX to EX
  signal ex_is_in_delayslot: STD_LOGIC;
  signal ex_link_address: STD_LOGIC_VECTOR(31 downto 0);
-- ID/EX to ID
  signal is_in_delayslot: STD_LOGIC;

-- IF/ID to ID
  signal pc: STD_LOGIC_VECTOR(31 downto 0);
  signal id_pc_i: STD_LOGIC_VECTOR(31 downto 0);
  signal id_inst_i: STD_LOGIC_VECTOR(31 downto 0);

-- ID to ID/EX
  signal id_aluop_o: STD_LOGIC_VECTOR(7 downto 0);
  signal id_alusel_o: STD_LOGIC_VECTOR(2 downto 0);
  signal id_reg1_o: STD_LOGIC_VECTOR(31 downto 0);
  signal id_reg2_o: STD_LOGIC_VECTOR(31 downto 0);
  signal id_wreg_o: STD_LOGIC;
  signal id_wd_o: STD_LOGIC_VECTOR(4 downto 0);
  signal id_inst: STD_LOGIC_VECTOR(31 downto 0);
  signal excepttype_id: STD_LOGIC_VECTOR(31 downto 0);
  signal current_inst_addr_id: STD_LOGIC_VECTOR(31 downto 0);

-- ID/EX to EX
  signal ex_aluop_i: STD_LOGIC_VECTOR(7 downto 0);
  signal ex_alusel_i: STD_LOGIC_VECTOR(2 downto 0);
  signal ex_reg1_i: STD_LOGIC_VECTOR(31 downto 0);
  signal ex_reg2_i: STD_LOGIC_VECTOR(31 downto 0);
  signal ex_wreg_i: STD_LOGIC;
  signal ex_wd_i: STD_LOGIC_VECTOR(4 downto 0);
  signal ex_inst: STD_LOGIC_VECTOR(31 downto 0);
  signal excepttype_id_ex: STD_LOGIC_VECTOR(31 downto 0);
  signal current_inst_addr_id_ex: STD_LOGIC_VECTOR(31 downto 0);

-- EX to EX/MEM
  signal ex_wreg_o: STD_LOGIC;
  signal ex_wd_o: STD_LOGIC_VECTOR(4 downto 0);
  signal ex_wdata_o: STD_LOGIC_VECTOR(31 downto 0);
  signal ex_whilo_o: STD_LOGIC;
  signal ex_hi_o: STD_LOGIC_VECTOR(31 downto 0);
  signal ex_lo_o: STD_LOGIC_VECTOR(31 downto 0);
  signal ex_aluop: STD_LOGIC_VECTOR(7 downto 0);
  signal ex_mem_addr: STD_LOGIC_VECTOR(31 downto 0);
  signal ex_reg2: STD_LOGIC_VECTOR(31 downto 0);
  signal ex_cp0_reg_data_o: STD_LOGIC_VECTOR(31 downto 0);
  signal ex_cp0_reg_write_addr_o: STD_LOGIC_VECTOR(4 downto 0);
  signal ex_cp0_reg_we_o: STD_LOGIC;
  signal excepttype_ex: STD_LOGIC_VECTOR(31 downto 0);
  signal current_inst_addr_ex: STD_LOGIC_VECTOR(31 downto 0);
  signal is_in_delayslot_ex: STD_LOGIC;

-- EX/MEM to MEM
  signal mem_wreg_i: STD_LOGIC;
  signal mem_wd_i: STD_LOGIC_VECTOR(4 downto 0);
  signal mem_wdata_i: STD_LOGIC_VECTOR(31 downto 0);
  signal mem_whilo_i: STD_LOGIC;
  signal mem_hi_i: STD_LOGIC_VECTOR(31 downto 0);
  signal mem_lo_i: STD_LOGIC_VECTOR(31 downto 0);
  signal mem_aluop: STD_LOGIC_VECTOR(7 downto 0);
  signal mem_addr: STD_LOGIC_VECTOR(31 downto 0);
  signal mem_reg2: STD_LOGIC_VECTOR(31 downto 0);
  signal mem_cp0_reg_data_i: STD_LOGIC_VECTOR(31 downto 0);
  signal mem_cp0_reg_write_addr_i: STD_LOGIC_VECTOR(4 downto 0);
  signal mem_cp0_reg_we_i: STD_LOGIC;
  signal excepttype_ex_mem: STD_LOGIC_VECTOR(31 downto 0);
  signal current_inst_addr_ex_mem: STD_LOGIC_VECTOR(31 downto 0);
  signal is_in_delayslot_ex_mem: STD_LOGIC;

-- MEM to CP0
  signal cp0_cause: STD_LOGIC_VECTOR(31 downto 0);
  signal cp0_status: STD_LOGIC_VECTOR(31 downto 0);
  signal cp0_epc: STD_LOGIC_VECTOR(31 downto 0);
  signal bad_addr_mem: STD_LOGIC_VECTOR(31 downto 0);
  signal excepttype_mem: STD_LOGIC_VECTOR(31 downto 0);
  signal current_inst_addr_mem: STD_LOGIC_VECTOR(31 downto 0);
  signal is_in_delayslot_mem: STD_LOGIC;

-- MEM to CTRL
  signal cp0_epc_mem: STD_LOGIC_VECTOR(31 downto 0);



-- MEM to MEM/WB
  signal mem_wreg_o: STD_LOGIC;
  signal mem_wd_o: STD_LOGIC_VECTOR(4 downto 0);
  signal mem_wdata_o: STD_LOGIC_VECTOR(31 downto 0);
  signal mem_whilo_o: STD_LOGIC;
  signal mem_hi_o: STD_LOGIC_VECTOR(31 downto 0);
  signal mem_lo_o: STD_LOGIC_VECTOR(31 downto 0);
  signal mem_cp0_reg_data_o: STD_LOGIC_VECTOR(31 downto 0);
  signal mem_cp0_reg_write_addr_o: STD_LOGIC_VECTOR(4 downto 0);
  signal mem_cp0_reg_we_o: STD_LOGIC;

-- MEM/MB to rewrite
  signal wb_wreg_i: STD_LOGIC;
  signal wb_wd_i: STD_LOGIC_VECTOR(4 downto 0);
  signal wb_wdata_i: STD_LOGIC_VECTOR(31 downto 0);
  signal wb_whilo_i: STD_LOGIC;
  signal wb_hi_i: STD_LOGIC_VECTOR(31 downto 0);
  signal wb_lo_i: STD_LOGIC_VECTOR(31 downto 0);
  signal wb_cp0_reg_data_i: STD_LOGIC_VECTOR(31 downto 0);
  signal wb_cp0_reg_write_addr_i: STD_LOGIC_VECTOR(4 downto 0);
  signal wb_cp0_reg_we_i: STD_LOGIC;

-- ID to Regfile
  signal reg1_read: STD_LOGIC;
  signal reg2_read: STD_LOGIC;
  signal reg1_data: STD_LOGIC_VECTOR(31 downto 0);
  signal reg2_data: STD_LOGIC_VECTOR(31 downto 0);
  signal reg1_addr: STD_LOGIC_VECTOR(4 downto 0);
  signal reg2_addr: STD_LOGIC_VECTOR(4 downto 0);

-- HILO to EX
  signal ex_hi_i: STD_LOGIC_VECTOR(31 downto 0);
  signal ex_lo_i: STD_LOGIC_VECTOR(31 downto 0);

-- EX to CP0
  signal ex_cp0: STD_LOGIC_VECTOR(4 downto 0);

--CP0 to EX
  signal cp0_reg_data_i: STD_LOGIC_VECTOR(31 downto 0);

begin
  inst_addr <= pc;

  clock0: clock port map(
    clk => clk, rst => rst, clk_new => clk_new
    );

  -- flush new_pc
  pc_reg0: pc_reg port map(
    clk => clk_new, rst => rst, pc => pc, ce => inst_ce,
    stall => stall, branch_target_address_i => branch_target_address,
    branch_flag_i => branch_flag, flush => flush, new_pc => new_pc);



  if_id0: if_id port map(clk => clk_new, rst => rst, if_pc => pc, if_inst => inst_data, id_pc => id_pc_i, id_inst => id_inst_i, stall => stall, flush => flush);

  id0: id port map(
    rst => rst, pc_i => id_pc_i, inst_i => id_inst_i,
    reg1_data_i => reg1_data, reg2_data_i => reg2_data,
    ex_wreg_i => ex_wreg_o, ex_wdata_i => ex_wdata_o,
    ex_wd_i => ex_wd_o, mem_wreg_i => mem_wreg_o,
    mem_wdata_i => mem_wdata_o, mem_wd_i => mem_wd_o,
    reg1_read_o => reg1_read, reg2_read_o => reg2_read,
    reg1_addr_o => reg1_addr, reg2_addr_o => reg2_addr,
    aluop_o => id_aluop_o, alusel_o => id_alusel_o,
    reg1_o => id_reg1_o, reg2_o => id_reg2_o,
    wd_o => id_wd_o, wreg_o => id_wreg_o, stallreq => stallreq_from_id,
    is_in_delayslot_i => is_in_delayslot, is_in_delayslot_o => id_is_in_delayslot,
    link_addr_o => id_link_address, next_inst_in_delayslot_o => next_inst_in_delayslot,
    branch_target_address_o => branch_target_address, branch_flag_o => branch_flag,
    inst_o => id_inst, ex_aluop_i => ex_aluop, excepttype_o => excepttype_id, current_inst_addr_o => current_inst_addr_id);

  regfile0: regfile port map(
    clk => clk_new, rst => rst,
    we => wb_wreg_i, waddr => wb_wd_i,
    wdata => wb_wdata_i, re1 => reg1_read,
    raddr1 => reg1_addr, rdata1 => reg1_data,
    re2 => reg2_read, raddr2 => reg2_addr,
    rdata2 => reg2_data);


  id_ex0: id_ex port map(
    clk => clk_new, rst => rst,
    id_aluop => id_aluop_o, id_alusel => id_alusel_o,
    id_reg1 => id_reg1_o, id_reg2 => id_reg2_o,
    id_wd => id_wd_o, id_wreg => id_wreg_o,
    ex_aluop => ex_aluop_i, ex_alusel => ex_alusel_i,
    ex_reg1 => ex_reg1_i, ex_reg2 => ex_reg2_i,
    ex_wd => ex_wd_i, ex_wreg => ex_wreg_i, stall => stall,
    id_is_in_delayslot => id_is_in_delayslot, id_link_address => id_link_address,
    next_inst_in_delayslot_i => next_inst_in_delayslot, ex_is_in_delayslot => ex_is_in_delayslot,
    ex_link_address => ex_link_address, is_in_delayslot_o => is_in_delayslot,
    id_inst => id_inst, ex_inst => ex_inst, flush => flush, id_excepttype => excepttype_id, id_current_inst_addr => current_inst_addr_id,
    ex_excepttype => excepttype_id_ex, ex_current_inst_addr => current_inst_addr_id_ex);

  ex0: ex port map(
    rst => rst,
    aluop_i => ex_aluop_i, alusel_i => ex_alusel_i,
    reg1_i => ex_reg1_i, reg2_i => ex_reg2_i,
    wd_i => ex_wd_i, wreg_i => ex_wreg_i,
    hi_i => ex_hi_i, lo_i => ex_lo_i,
    wb_whilo_i => wb_whilo_i, wb_hi_i => wb_hi_i,
    wb_lo_i => wb_lo_i, mem_whilo_i => mem_whilo_o,
    mem_hi_i => mem_hi_o, mem_lo_i => mem_lo_o,
    wd_o => ex_wd_o, wreg_o => ex_wreg_o,
    wdata_o => ex_wdata_o, whilo_o => ex_whilo_o,
    hi_o => ex_hi_o, lo_o => ex_lo_o, stallreq => stallreq_from_ex,
    is_in_delayslot_i => ex_is_in_delayslot, link_address_i => ex_link_address,
    inst_i => ex_inst, aluop_o => ex_aluop, mem_addr_o => ex_mem_addr, reg2_o => ex_reg2,
    wb_cp0_reg_data => wb_cp0_reg_data_i, wb_cp0_reg_write_addr => wb_cp0_reg_write_addr_i, wb_cp0_reg_we => wb_cp0_reg_we_i,
    mem_cp0_reg_data => mem_cp0_reg_data_o, mem_cp0_reg_write_addr => mem_cp0_reg_write_addr_o, mem_cp0_reg_we => mem_cp0_reg_we_o,
    cp0_reg_read_addr_o => ex_cp0, cp0_reg_data_o => ex_cp0_reg_data_o, cp0_reg_write_addr_o => ex_cp0_reg_write_addr_o, cp0_reg_we_o => ex_cp0_reg_we_o,
    cp0_reg_data_i => cp0_reg_data_i, excepttype_i => excepttype_id_ex, current_inst_addr_i => current_inst_addr_id_ex, excepttype_o => excepttype_ex, current_inst_addr_o => current_inst_addr_ex,
    is_in_delayslot_o => is_in_delayslot_ex);

  ex_mem0: ex_mem port map(
    clk => clk_new, rst => rst,
    ex_wd => ex_wd_o, ex_wreg => ex_wreg_o,
    ex_wdata => ex_wdata_o, ex_whilo => ex_whilo_o,
    ex_hi => ex_hi_o, ex_lo => ex_lo_o,
    mem_wd => mem_wd_i, mem_wreg => mem_wreg_i,
    mem_wdata => mem_wdata_i, mem_whilo => mem_whilo_i,
    mem_hi => mem_hi_i, mem_lo => mem_lo_i, stall => stall,
    ex_aluop => ex_aluop, ex_mem_addr => ex_mem_addr, ex_reg2 => ex_reg2,
    mem_aluop => mem_aluop, mem_mem_addr => mem_addr, mem_reg2 => mem_reg2,
    ex_cp0_reg_data => ex_cp0_reg_data_o, ex_cp0_reg_write_addr => ex_cp0_reg_write_addr_o, ex_cp0_reg_we => ex_cp0_reg_we_o,
    mem_cp0_reg_data => mem_cp0_reg_data_i, mem_cp0_reg_write_addr => mem_cp0_reg_write_addr_i, mem_cp0_reg_we => mem_cp0_reg_we_i, flush => flush,
    ex_excepttype => excepttype_ex, ex_current_inst_addr => current_inst_addr_ex, ex_is_in_delayslot => is_in_delayslot_ex,
    mem_excepttype => excepttype_ex_mem, mem_current_inst_addr => current_inst_addr_ex_mem, mem_is_in_delayslot => is_in_delayslot_ex_mem);

  mem0: mem port map(
    rst => rst,
    wd_i => mem_wd_i, wreg_i => mem_wreg_i,
    wdata_i => mem_wdata_i, whilo_i => mem_whilo_i,
    hi_i => mem_hi_i, lo_i => mem_lo_i,
    mem_data_i => ram_data_i, mem_addr_o => ram_addr_o,
    mem_we_o => ram_we_o, mem_align => ram_align,
    mem_data_o => ram_data_o, mem_ce_o => ram_ce_o,
    wd_o => mem_wd_o, wreg_o => mem_wreg_o,
    wdata_o => mem_wdata_o, whilo_o => mem_whilo_o,
    hi_o => mem_hi_o, lo_o => mem_lo_o,
    aluop_i => mem_aluop, mem_addr_i => mem_addr, reg2_i => mem_reg2,
    cp0_reg_data_i => mem_cp0_reg_data_i, cp0_reg_write_addr_i => mem_cp0_reg_write_addr_i, cp0_reg_we_i => mem_cp0_reg_we_i,
    cp0_reg_data_o => mem_cp0_reg_data_o, cp0_reg_write_addr_o => mem_cp0_reg_write_addr_o, cp0_reg_we_o => mem_cp0_reg_we_o,
    excepttype_i => excepttype_ex_mem, current_inst_addr_i => current_inst_addr_ex_mem, is_in_delayslot_i => is_in_delayslot_ex_mem,
    cp0_epc_i => cp0_epc, cp0_status_i => cp0_status, cp0_cause_i => cp0_cause, wb_cp0_reg_data => wb_cp0_reg_data_i,
    wb_cp0_reg_we => wb_cp0_reg_we_i, wb_cp0_reg_write_addr => wb_cp0_reg_write_addr_i, mmu_exc_code => exc_code_mmu, mmu_badAddr => bad_addr_mmu,
    badAddr_o => bad_addr_mem, excepttype_o => excepttype_mem, current_inst_addr_o => current_inst_addr_mem, is_in_delayslot_o => is_in_delayslot_mem,
    cp0_epc_o => cp0_epc_mem, Index_i => Index, EntryLo0_i => EntryLo0, EntryLo1_i => EntryLo1, PageMask_i => PageMask, EntryHi_i => EntryHi,
    tlb_write_struct => tlb_write_struct, tlb_write_enable => tlb_write_enable);

  mem_wb0: mem_wb port map(
    clk => clk_new, rst => rst,
    mem_wd => mem_wd_o, mem_wreg => mem_wreg_o,
    mem_wdata => mem_wdata_o, mem_whilo => mem_whilo_o,
    mem_hi => mem_hi_o, mem_lo => mem_lo_o,
    wb_wd => wb_wd_i, wb_wreg => wb_wreg_i,
    wb_wdata => wb_wdata_i, wb_whilo => wb_whilo_i,
    wb_hi => wb_hi_i, wb_lo => wb_lo_i, stall => stall,
    mem_cp0_reg_data => mem_cp0_reg_data_o, mem_cp0_reg_write_addr => mem_cp0_reg_write_addr_o, mem_cp0_reg_we => mem_cp0_reg_we_o,
    wb_cp0_reg_data => wb_cp0_reg_data_i, wb_cp0_reg_write_addr => wb_cp0_reg_write_addr_i, wb_cp0_reg_we => wb_cp0_reg_we_i, flush => flush
    );

  hilo_reg0: hilo_reg port map(
    clk => clk_new, rst => rst,
    we => wb_whilo_i, hi_i => wb_hi_i,
    lo_i => wb_lo_i, hi_o => ex_hi_i,
    lo_o => ex_lo_i);

  cp0_reg0: cp0_reg port map(
    clk => clk_new, rst => rst,
    data_i => wb_cp0_reg_data_i, waddr_i => wb_cp0_reg_write_addr_i, we_i => wb_cp0_reg_we_i,
    raddr_i => ex_cp0, data_o => cp0_reg_data_i, mmu_int_i => serial_int_mmu,
    excepttype_i => excepttype_mem, current_inst_addr_i => current_inst_addr_mem, is_in_delayslot_i => is_in_delayslot_mem, badAddr_i => bad_addr_mem,
    Status_o => cp0_status, Cause_o => cp0_cause, EPC_o => cp0_epc, Index_o => Index, EntryHi_o => EntryHi, EntryLo0_o => EntryLo0,
    EntryLo1_o => EntryLo1, PageMask_o => PageMask, BadVAddr_o => BadVAddr, Count_o => Count, Compare_o => Compare,
    EBase_o => EBase, timer_int_o => timer_int
  );

  ctrl0: ctrl port map(
    rst => rst, stallreq_from_ex => stallreq_from_ex, stallreq_from_id => stallreq_from_id, stall => stall, stallreq_from_mem => stallreq_from_mem, cp0_epc_i => cp0_epc_mem, excepttype_i => excepttype_mem,
    new_pc => new_pc, flush => flush);

  memcontrol0: memcontrol port map(
    rst => rst, clk => clk, inst_data_i => inst_data, inst_addr_o => inst_addr, inst_ce_o => inst_ce, ram_data_i => ram_data_i,
    ram_addr_o => ram_addr_o, ram_data_o => ram_data_o, ram_we_o => ram_we_o, ram_align => ram_align, ram_ce_o => ram_ce_o, stallreq => stallreq_from_mem,
    ope_addr => ope_addr, write_data => ope_data, read_data => mmu_result_data, ope_we => ope_we, ope_ce => ope_ce, data_ready => data_ready
    );

  mmu0: mmu port map(
    clk => clk, rst => rst, ope_addr => ope_addr, write_data => ope_data, ope_we => ope_we, ope_ce => ope_ce, read_data => mmu_result_data, ready => data_ready,
    align_type => align_type, serial_int => serial_int_mmu, exc_code => exc_code_mmu, tlb_write_struct => tlb_write_struct, tlb_write_enable => tlb_write_enable,
    to_physical_addr => to_physical_addr, to_physical_data => to_physical_data, to_physical_read_enable => to_physical_read_enable, to_physical_write_enable => to_physical_write_enable,
    from_physical_data => from_physical_data, from_physical_ready => from_physical_ready, from_physical_serial => from_physical_serial
    );


end architecture ; -- arch
