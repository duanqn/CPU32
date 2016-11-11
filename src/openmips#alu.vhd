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
    rom_ce_o: out STD_LOGIC);
end openmips;

architecture arch of openmips is

  component pc_reg
  port(
    clk: in STD_LOGIC;
    rst: in STD_LOGIC;
    stall: in STD_LOGIC_VECTOR(5 downto 0);
    pc: buffer STD_LOGIC_VECTOR(31 downto 0);
    ce: buffer STD_LOGIC
    );
  end component;

  component if_id
  port(
    clk: in STD_LOGIC;
    rst: in STD_LOGIC;
    if_pc: in STD_LOGIC_VECTOR(31 downto 0);
    if_inst: in STD_LOGIC_VECTOR(31 downto 0);
    stall: in STD_LOGIC_VECTOR(5 downto 0);
    id_pc: out STD_LOGIC_VECTOR(31 downto 0);
    id_inst: out STD_LOGIC_VECTOR(31 downto 0)
    );
  end component;

  component id
  port(
    rst: in STD_LOGIC;
    pc_i: in STD_LOGIC_VECTOR(31 downto 0);
    inst_i: in STD_LOGIC_VECTOR(31 downto 0);
    
    reg1_data_i: in STD_LOGIC_VECTOR(31 downto 0);
    reg2_data_i: in STD_LOGIC_VECTOR(31 downto 0);

    ex_wreg_i: in STD_LOGIC;
    ex_wdata_i: in STD_LOGIC_VECTOR(31 downto 0);
    ex_wd_i: in STD_LOGIC_VECTOR(4 downto 0);

    mem_wreg_i: in STD_LOGIC;
    mem_wdata_i: in STD_LOGIC_VECTOR(31 downto 0);
    mem_wd_i: in STD_LOGIC_VECTOR(4 downto 0);

    
    stallreq: out STD_LOGIC_VECTOR(5 downto 0);
    reg1_read_o: buffer STD_LOGIC;
    reg2_read_o: buffer STD_LOGIC;
    reg1_addr_o: buffer STD_LOGIC_VECTOR(4 downto 0);
    reg2_addr_o: buffer STD_LOGIC_VECTOR(4 downto 0);

    aluop_o: out STD_LOGIC_VECTOR(7 downto 0);
    alusel_o: out STD_LOGIC_VECTOR(2 downto 0);
    reg1_o: out STD_LOGIC_VECTOR(31 downto 0);
    reg2_o: out STD_LOGIC_VECTOR(31 downto 0);
    wd_o: out STD_LOGIC_VECTOR(4 downto 0);
    wreg_o: out STD_LOGIC
    );
  end component;

  component regfile
  port(
    clk: in STD_LOGIC;
    rst: in STD_LOGIC;
    
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
    clk: in STD_LOGIC;
    rst: in STD_LOGIC;

    we: in STD_LOGIC;
    hi_i: in STD_LOGIC_VECTOR(31 downto 0);
    lo_i: in STD_LOGIC_VECTOR(31 downto 0);

    hi_o: out STD_LOGIC_VECTOR(31 downto 0);
    lo_o: out STD_LOGIC_VECTOR(31 downto 0)
    );
  end component;

  component id_ex
  port(
    clk: in STD_LOGIC;
    rst: in STD_LOGIC;

    id_aluop: in STD_LOGIC_VECTOR(7 downto 0);
    id_alusel: in STD_LOGIC_VECTOR(2 downto 0);
    id_reg1: in STD_LOGIC_VECTOR(31 downto 0);
    id_reg2: in STD_LOGIC_VECTOR(31 downto 0);
    id_wd: in STD_LOGIC_VECTOR(4 downto 0);
    id_wreg: in STD_LOGIC;
    stall: in STD_LOGIC_VECTOR(5 downto 0);

    ex_aluop: out STD_LOGIC_VECTOR(7 downto 0);
    ex_alusel: out STD_LOGIC_VECTOR(2 downto 0);
    ex_reg1: out STD_LOGIC_VECTOR(31 downto 0);
    ex_reg2: out STD_LOGIC_VECTOR(31 downto 0);
    ex_wd: out STD_LOGIC_VECTOR(4 downto 0);
    ex_wreg: out STD_LOGIC
    );
  end component;

  component ex
  port (
    rst: in STD_LOGIC;
	 
    aluop_i: in STD_LOGIC_VECTOR(7 downto 0);
    alusel_i: in STD_LOGIC_VECTOR(2 downto 0);
    reg1_i: in STD_LOGIC_VECTOR(31 downto 0);
    reg2_i: in STD_LOGIC_VECTOR(31 downto 0);
    wd_i: in STD_LOGIC_VECTOR(4 downto 0);
    wreg_i: in STD_LOGIC;

    hi_i: in STD_LOGIC_VECTOR(31 downto 0);
    lo_i: in STD_LOGIC_VECTOR(31 downto 0);

    wb_hi_i: in STD_LOGIC_VECTOR(31 downto 0);
    wb_lo_i: in STD_LOGIC_VECTOR(31 downto 0);
    wb_whilo_i: in STD_LOGIC;

    mem_hi_i: in STD_LOGIC_VECTOR(31 downto 0);
    mem_lo_i: in STD_LOGIC_VECTOR(31 downto 0);
    mem_whilo_i: in STD_LOGIC;

    stallreq: out STD_LOGIC_VECTOR(5 downto 0);
    hi_o: out STD_LOGIC_VECTOR(31 downto 0);
    lo_o: out STD_LOGIC_VECTOR(31 downto 0);
    whilo_o: out STD_LOGIC; 

    wd_o: out STD_LOGIC_VECTOR(4 downto 0);
    wreg_o: out STD_LOGIC;
    wdata_o: out STD_LOGIC_VECTOR(31 downto 0)
    );
  end component;

  component ex_mem
  port (
    clk: in STD_LOGIC;
    rst: in STD_LOGIC;

    ex_wd: in STD_LOGIC_VECTOR(4 downto 0);
    ex_wreg: in STD_LOGIC;
    ex_wdata: in STD_LOGIC_VECTOR(31 downto 0);

    ex_hi: in STD_LOGIC_VECTOR(31 downto 0);
    ex_lo: in STD_LOGIC_VECTOR(31 downto 0);
    ex_whilo: in STD_LOGIC_VECTOR(31 downto 0);
    stall: in STD_LOGIC_VECTOR(5 downto 0);

    mem_wd: out STD_LOGIC_VECTOR(4 downto 0);
    mem_wreg: out STD_LOGIC;
    mem_wdata: out STD_LOGIC_VECTOR(31 downto 0);
    mem_hi: out STD_LOGIC_VECTOR(31 downto 0);
    mem_lo: out STD_LOGIC_VECTOR(31 downto 0);
    mem_whilo: out STD_LOGIC
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

    wd_o: out STD_LOGIC_VECTOR(4 downto 0);
    wreg_o: out STD_LOGIC;
    wdata_o: out STD_LOGIC_VECTOR(31 downto 0);
    hi_o: out STD_LOGIC_VECTOR(31 downto 0);
    lo_o: out STD_LOGIC_VECTOR(31 downto 0);
    whilo_o: out STD_LOGIC
    );
  end component;

  component mem_wb
  port (
    clk: in STD_LOGIC;
    rst: in STD_LOGIC;

    mem_wd: in STD_LOGIC_VECTOR(4 downto 0);
    mem_wreg: in STD_LOGIC;
    mem_wdata: in STD_LOGIC_VECTOR(31 downto 0);

    mem_hi: in STD_LOGIC_VECTOR(31 downto 0);
    mem_lo: in STD_LOGIC_VECTOR(31 downto 0);
    mem_whilo: in STD_LOGIC;
    stall: in STD_LOGIC_VECTOR(5 downto 0);

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
  
-- stall
  signal stall: STD_LOGIC_VECTOR(5 downto 0);
  signal stallreq_from_ex: STD_LOGIC;
  signal stallreq_from_id: STD_LOGIC;

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

-- ID/EX to EX
  signal ex_aluop_i: STD_LOGIC_VECTOR(7 downto 0);
  signal ex_alusel_i: STD_LOGIC_VECTOR(2 downto 0);
  signal ex_reg1_i: STD_LOGIC_VECTOR(31 downto 0);
  signal ex_reg2_i: STD_LOGIC_VECTOR(31 downto 0);
  signal ex_wreg_i: STD_LOGIC;
  signal ex_wd_i: STD_LOGIC_VECTOR(4 downto 0);

-- EX to EX/MEM
  signal ex_wreg_o: STD_LOGIC;
  signal ex_wd_o: STD_LOGIC_VECTOR(4 downto 0);
  signal ex_wdata_o: STD_LOGIC_VECTOR(31 downto 0);
  signal ex_whilo_o: STD_LOGIC;
  signal ex_hi_o: STD_LOGIC_VECTOR(31 downto 0);
  signal ex_lo_o: STD_LOGIC_VECTOR(31 downto 0);

-- EX/MEM to MEM
  signal mem_wreg_i: STD_LOGIC;
  signal mem_wd_i: STD_LOGIC_VECTOR(4 downto 0);
  signal mem_wdata_i: STD_LOGIC_VECTOR(31 downto 0);
  signal mem_whilo_i: STD_LOGIC;
  signal mem_hi_i: STD_LOGIC_VECTOR(31 downto 0);
  signal mem_lo_i: STD_LOGIC_VECTOR(31 downto 0);

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
  pc_reg0: pc_reg port map(clk => clk, rst => rst, pc => pc, ce => rom_ce_o, stall => stall);

  rom_addr_o <= pc;

  if_id0: if_id port map(clk => clk, rst => rst, if_pc => pc, if_inst => rom_data_i, id_pc => id_pc_i, id_inst => id_inst_i, stall => stall);

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
    wd_o => id_wd_o, wreg_o => id_wreg_o, stallreq => stallreq_from_id);

  regfile0: regfile port map(
    clk => clk, rst => rst,
    we => wb_wreg_i, waddr => wb_wd_i, 
    wdata => wb_wdata_i, re1 => reg1_read,
    raddr1 => reg1_addr, rdata1 => reg1_data,
    re2 => reg2_read, raddr2 => reg2_addr,
    rdata2 => reg2_data);


  id_ex0: id_ex port map(
    clk => clk, rst => rst,
    id_aluop => id_aluop_o, id_alusel => id_alusel_o,
    id_reg1 => id_reg1_o, id_reg2 => id_reg2_o,
    id_wd => id_wd_o, id_wreg => id_wreg_o,
    ex_aluop => ex_aluop_i, ex_alusel => ex_alusel_i,
    ex_reg1 => ex_reg1_i, ex_reg2 => ex_reg2_i,
    ex_wd => ex_wd_i, ex_wreg => ex_wreg_i, stall => stall);

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
    hi_o => ex_hi_o, lo_o => ex_lo_o, stallreq => stallreq_from_ex);

  ex_mem0: ex_mem port map(
    clk => clk, rst => rst,
    ex_wd => ex_wd_o, ex_wreg => ex_wreg_o, 
    ex_wdata => ex_wdata_o, ex_whilo => ex_whilo_o,
    ex_hi => ex_hi_o, ex_lo => ex_lo_o,
    mem_wd => mem_wd_i, mem_wreg => mem_wreg_i,
    mem_wdata => mem_wdata_i, mem_whilo => mem_whilo_i,
    mem_hi => mem_hi_i, mem_lo => mem_lo_i, stall => stall);

  mem0: mem port map(
    rst => rst, 
    wd_i => mem_wd_i, wreg_i => mem_wreg_i,
    wdata_i => mem_wdata_i, whilo_i => mem_whilo_i,
    hi_i => mem_hi_i, lo_i => mem_lo_i,
    wd_o => mem_wd_o, wreg_o => mem_wreg_o,
    wdata_o => mem_wdata_o, whilo_o => mem_whilo_o,
    hi_o => mem_hi_o, lo_o => mem_lo_o);

  mem_wb0: mem_wb port map(
    clk => clk, rst => rst,
    mem_wd => mem_wd_o, mem_wreg => mem_wreg_o,
    mem_wdata => mem_wdata_o, mem_whilo => mem_whilo_o,
    mem_hi => mem_hi_o, mem_lo => mem_lo_o,
    wb_wd => wb_wd_i, wb_wreg => wb_wreg_i,
    wb_wdata => wb_wdata_i, wb_whilo => wb_whilo_i,
    wb_hi => wb_hi_i, wb_lo => wb_lo_i, stall => stall);

  hilo_reg0: hilo_reg port map(
    clk => clk, rst => rst,
    we => wb_whilo_i, hi_i => wb_hi_i,
    lo_i => wb_lo_i, hi_o => ex_hi_i,
    lo_o => ex_lo_i);

  ctrl0: ctrl port map(
    rst => rst, stallreq_from_ex => stallreq_from_ex, stallreq_from_id => stallreq_from_id, stall => stall);


end architecture ; -- arch
