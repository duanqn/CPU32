LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
use work.CPU32.all;

ENTITY openmips is
  port(
    rst: in STD_LOGIC;
    clk: in STD_LOGIC;

    rom_data_i: in STD_LOGIC_VECTOR(31 downto 0);
    rom_addr_o: out STD_LOGIC_VECTOR(31 downto 0);
    rom_ce_o: buffer STD_LOGIC;

    ram_data_i: in STD_LOGIC_VECTOR(31 downto 0);
    ram_addr_o: out STD_LOGIC_VECTOR(31 downto 0);
    ram_data_o: out STD_LOGIC_VECTOR(31 downto 0);
    ram_we_o: out STD_LOGIC;
    ram_sel_o: out STD_LOGIC_VECTOR(3 downto 0);
    ram_ce_o: out STD_LOGIC
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
    ce: buffer STD_LOGIC
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
    id_inst:out STD_LOGIC_VECTOR(31 downto 0)
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
    ex_aluop_i:in STD_LOGIC_VECTOR(7 downto 0)
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
    is_in_delayslot_o: OUT STD_LOGIC
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
    mem_hi_i: IN STD_LOGIC_VECTOR(31 downto 0);
    mem_lo_i: IN STD_LOGIC_VECTOR(31 downto 0);
    mem_whilo_i: IN STD_LOGIC;

    link_address_i: IN STD_LOGIC_VECTOR(31 downto 0);
    is_in_delayslot_i: IN STD_LOGIC;

    inst_i: IN STD_LOGIC_VECTOR(31 downto 0);

    stallreq: OUT STD_LOGIC;
    hi_o: OUT STD_LOGIC_VECTOR(31 downto 0);
    lo_o: OUT STD_LOGIC_VECTOR(31 downto 0);
    whilo_o: OUT STD_LOGIC;

    wd_o: OUT STD_LOGIC_VECTOR(4 downto 0);
    wreg_o: OUT STD_LOGIC;
    wdata_o: OUT STD_LOGIC_VECTOR(31 downto 0);

    aluop_o: OUT STD_LOGIC_VECTOR(7 downto 0);
    mem_addr_o: OUT STD_LOGIC_VECTOR(31 downto 0);
    reg2_o: OUT STD_LOGIC_VECTOR(31 downto 0)
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
    stall: IN STD_LOGIC_VECTOR(5 downto 0);

    mem_wd: BUFFER STD_LOGIC_VECTOR (4 downto 0);
    mem_wreg: BUFFER STD_LOGIC;
    mem_wdata: BUFFER STD_LOGIC_VECTOR (31 downto 0);
    mem_hi: OUT STD_LOGIC_VECTOR (31 downto 0);
    mem_lo: OUT STD_LOGIC_VECTOR (31 downto 0);
    mem_whilo: OUT STD_LOGIC;
    mem_aluop: OUT STD_LOGIC_VECTOR (7 downto 0);
    mem_mem_addr: OUT STD_LOGIC_VECTOR (31 downto 0);
    mem_reg2: OUT STD_LOGIC_VECTOR (31 downto 0)
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


    mem_addr_o: out STD_LOGIC_VECTOR(31 downto 0);
    mem_we_o: out STD_LOGIC;
    mem_sel_o: out STD_LOGIC_VECTOR(3 downto 0);
    mem_data_o: out STD_LOGIC_VECTOR(31 downto 0);
    mem_ce_o: out STD_LOGIC;

    wd_o: out STD_LOGIC_VECTOR(4 downto 0);
    wreg_o: out STD_LOGIC;
    wdata_o: out STD_LOGIC_VECTOR(31 downto 0);
    hi_o: out STD_LOGIC_VECTOR(31 downto 0);
    lo_o: out STD_LOGIC_VECTOR(31 downto 0);
    whilo_o:out STD_LOGIC
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
    stall: in STD_LOGIC_VECTOR(5 downto 0);
    
    -- output
    wb_wd: out STD_LOGIC_VECTOR(4 downto 0);
    wb_wreg: out STD_LOGIC;
    wb_wdata: out STD_LOGIC_VECTOR(31 downto 0);
    wb_hi: out STD_LOGIC_VECTOR(31 downto 0);
    wb_lo: out STD_LOGIC_VECTOR(31 downto 0);
    wb_whilo: out STD_LOGIC
    );
  end component;

  component ctrl
  port (
    rst: IN STD_LOGIC;
    stallreq_from_id: IN STD_LOGIC;
    stallreq_from_ex: IN STD_LOGIC;
    stall: OUT STD_LOGIC_VECTOR(5 downto 0)
    );
  end component;

-- clock 
  signal clk_new: STD_LOGIC := '0';
  
-- stall
  signal stall: STD_LOGIC_VECTOR(5 downto 0);
  signal stallreq_from_ex: STD_LOGIC;
  signal stallreq_from_id: STD_LOGIC;

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

-- ID/EX to EX
  signal ex_aluop_i: STD_LOGIC_VECTOR(7 downto 0);
  signal ex_alusel_i: STD_LOGIC_VECTOR(2 downto 0);
  signal ex_reg1_i: STD_LOGIC_VECTOR(31 downto 0);
  signal ex_reg2_i: STD_LOGIC_VECTOR(31 downto 0);
  signal ex_wreg_i: STD_LOGIC;
  signal ex_wd_i: STD_LOGIC_VECTOR(4 downto 0);
  signal ex_inst: STD_LOGIC_VECTOR(31 downto 0);

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


-- MEM to MEM/WB
  signal mem_wreg_o: STD_LOGIC;
  signal mem_wd_o: STD_LOGIC_VECTOR(4 downto 0);
  signal mem_wdata_o: STD_LOGIC_VECTOR(31 downto 0);
  signal mem_whilo_o: STD_LOGIC;
  signal mem_hi_o: STD_LOGIC_VECTOR(31 downto 0);
  signal mem_lo_o: STD_LOGIC_VECTOR(31 downto 0);


-- MEM/MB to rewrite
  signal wb_wreg_i: STD_LOGIC;
  signal wb_wd_i: STD_LOGIC_VECTOR(4 downto 0);
  signal wb_wdata_i: STD_LOGIC_VECTOR(31 downto 0);
  signal wb_whilo_i: STD_LOGIC;
  signal wb_hi_i: STD_LOGIC_VECTOR(31 downto 0);
  signal wb_lo_i: STD_LOGIC_VECTOR(31 downto 0);

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

begin
  rom_addr_o <= pc;

  clock0: clock port map(
    clk => clk, rst => rst, clk_new => clk_new
    );

  pc_reg0: pc_reg port map(
    clk => clk_new, rst => rst, pc => pc, ce => rom_ce_o, 
    stall => stall, branch_target_address_i => branch_target_address,
    branch_flag_i => branch_flag);

  

  if_id0: if_id port map(clk => clk_new, rst => rst, if_pc => pc, if_inst => rom_data_i, id_pc => id_pc_i, id_inst => id_inst_i, stall => stall);

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
    inst_o => id_inst, ex_aluop_i => ex_aluop);

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
    id_inst => id_inst, ex_inst => ex_inst);

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
    inst_i => ex_inst, aluop_o => ex_aluop, mem_addr_o => ex_mem_addr, reg2_o => ex_reg2);

  ex_mem0: ex_mem port map(
    clk => clk_new, rst => rst,
    ex_wd => ex_wd_o, ex_wreg => ex_wreg_o, 
    ex_wdata => ex_wdata_o, ex_whilo => ex_whilo_o,
    ex_hi => ex_hi_o, ex_lo => ex_lo_o,
    mem_wd => mem_wd_i, mem_wreg => mem_wreg_i,
    mem_wdata => mem_wdata_i, mem_whilo => mem_whilo_i,
    mem_hi => mem_hi_i, mem_lo => mem_lo_i, stall => stall, 
    ex_aluop => ex_aluop, ex_mem_addr => ex_mem_addr, ex_reg2 => ex_reg2,
    mem_aluop => mem_aluop, mem_mem_addr => mem_addr, mem_reg2 => mem_reg2);

  mem0: mem port map(
    rst => rst, 
    wd_i => mem_wd_i, wreg_i => mem_wreg_i,
    wdata_i => mem_wdata_i, whilo_i => mem_whilo_i,
    hi_i => mem_hi_i, lo_i => mem_lo_i,
    mem_data_i => ram_data_i, mem_addr_o => ram_addr_o,
    mem_we_o => ram_we_o, mem_sel_o => ram_sel_o,
    mem_data_o => ram_data_o, mem_ce_o => ram_ce_o,
    wd_o => mem_wd_o, wreg_o => mem_wreg_o,
    wdata_o => mem_wdata_o, whilo_o => mem_whilo_o,
    hi_o => mem_hi_o, lo_o => mem_lo_o,
    aluop_i => mem_aluop, mem_addr_i => mem_addr, reg2_i => mem_reg2);

  mem_wb0: mem_wb port map(
    clk => clk_new, rst => rst,
    mem_wd => mem_wd_o, mem_wreg => mem_wreg_o,
    mem_wdata => mem_wdata_o, mem_whilo => mem_whilo_o,
    mem_hi => mem_hi_o, mem_lo => mem_lo_o,
    wb_wd => wb_wd_i, wb_wreg => wb_wreg_i,
    wb_wdata => wb_wdata_i, wb_whilo => wb_whilo_i,
    wb_hi => wb_hi_i, wb_lo => wb_lo_i, stall => stall);

  hilo_reg0: hilo_reg port map(
    clk => clk_new, rst => rst,
    we => wb_whilo_i, hi_i => wb_hi_i,
    lo_i => wb_lo_i, hi_o => ex_hi_i,
    lo_o => ex_lo_i);

  ctrl0: ctrl port map(
    rst => rst, stallreq_from_ex => stallreq_from_ex, stallreq_from_id => stallreq_from_id, stall => stall);


end architecture ; -- arch
