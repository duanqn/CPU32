LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;
use work.CPU32.all;


ENTITY ex_mem IS
  PORT(
    clk: IN STD_LOGIC;
    rst: IN STD_LOGIC;

    ex_wd: IN STD_LOGIC_VECTOR (4 downto 0);              --5bit  执行阶段的指令执行后要写入的目的寄存器地址
    ex_wreg: IN STD_LOGIC;                                --1bit  执行阶段的指令执行后是否有要写入的目的寄存器
    ex_wdata: IN STD_LOGIC_VECTOR (31 downto 0);          --32bit 执行阶段的指令执行后是否有要写入的目的寄存器的值
    ex_hi: IN STD_LOGIC_VECTOR (31 downto 0);             --32bit 执行阶段的指令要写入HI寄存器的值
    ex_lo: IN STD_LOGIC_VECTOR (31 downto 0);             --32bit 执行阶段的指令要写入LO寄存器的值
    ex_whilo: IN STD_LOGIC;                               --1bit  执行阶段的指令是否要写HI、LO寄存器
    ex_aluop: IN STD_LOGIC_VECTOR (7 downto 0);           --8bit  执行阶段的指令要进行的运算的子类型
    ex_mem_addr: IN STD_LOGIC_VECTOR (31 downto 0);       --32bit 执行阶段的加载、存储指令对应的存储器地址
    ex_reg2: IN STD_LOGIC_VECTOR (31 downto 0);           --32bit 执行阶段的存储指令要存储的数据
    stall: IN STD_LOGIC_VECTOR(5 downto 0);

    mem_wd: BUFFER STD_LOGIC_VECTOR (4 downto 0);         --5bit  访存阶段的指令要写入目的寄存器的值
    mem_wreg: BUFFER STD_LOGIC;                           --1bit  访存阶段的指令是否有要写入的目的寄存器
    mem_wdata: BUFFER STD_LOGIC_VECTOR (31 downto 0);     --32bit 访存阶段的指令要写入目的寄存器的值
    mem_hi: OUT STD_LOGIC_VECTOR (31 downto 0);           --32bit 访存阶段的指令要写入HI寄存器的值
    mem_lo: OUT STD_LOGIC_VECTOR (31 downto 0);           --32bit 访存阶段的指令要写入LO寄存器的值
    mem_whilo: OUT STD_LOGIC;                             --1bit  访存阶段的指令是否要写入HI、LO寄存器
    mem_aluop: OUT STD_LOGIC_VECTOR (7 downto 0);         --8bit  访存阶段的指令要进行运算的子类型
    mem_mem_addr: OUT STD_LOGIC_VECTOR (31 downto 0);     --32bit 访存阶段的加载、存储指令对应的存储器地址
    mem_reg2: OUT STD_LOGIC_VECTOR (31 downto 0)          --32bit 访存阶段的存储指令要存储的数据
  );
end ex_mem;

  ARCHITECTURE behave OF ex_mem IS
    
  BEGIN
    PROCESS(clk, rst, stall)
      BEGIN
		IF (clk'event and clk = '1') THEN                    --时钟上升沿
          IF (rst = '0') THEN
            mem_wd <= "00000";
            mem_wreg <= '0';
            mem_wdata <= X"00000000";
            mem_hi <= X"00000000";
            mem_lo <= X"00000000";
            mem_whilo <= '0';
				mem_aluop <= "00000000";
				mem_mem_addr <= X"00000000";
				mem_reg2 <= X"00000000";
          
			 ELSIF (stall(3) = '1' and stall(4) = '0') THEN
            mem_wd <= "00000";
            mem_wreg <= '0';
            mem_wdata <= X"00000000";
            mem_hi <= X"00000000";
            mem_lo <= X"00000000";
            mem_whilo <= '0';
				mem_aluop <= "00000000";
				mem_mem_addr <= X"00000000";
				mem_reg2 <= X"00000000";
				
          ELSIF (stall(3) = '0') THEN
            mem_wd <= ex_wd;
            mem_wreg <= ex_wreg;
            mem_wdata <= ex_wdata;
            mem_hi <= ex_hi;
            mem_lo <= ex_lo;
            mem_whilo <= ex_whilo;
            mem_aluop <= ex_aluop;
            mem_mem_addr <= ex_mem_addr;
            mem_reg2 <= ex_reg2;
          END IF;
        END IF;
      END PROCESS;
    END;
