LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;
use work.CPU32.all;


ENTITY ex_mem IS
  PORT(
    clk: IN STD_LOGIC;
    rst: IN STD_LOGIC;

    ex_wd: IN STD_LOGIC_VECTOR (4 downto 0);              --5bit  ִ�н׶ε�ָ��ִ�к�Ҫд����Ŀ�ļĴ�����ַ
    ex_wreg: IN STD_LOGIC;                                --1bit  ִ�н׶ε�ָ��ִ�к��Ƿ���Ҫд����Ŀ�ļĴ���
    ex_wdata: IN STD_LOGIC_VECTOR (31 downto 0);          --32bit ִ�н׶ε�ָ��ִ�к��Ƿ���Ҫд����Ŀ�ļĴ�����ֵ
    ex_hi: IN STD_LOGIC_VECTOR (31 downto 0);             --32bit ִ�н׶ε�ָ��Ҫд��HI�Ĵ�����ֵ
    ex_lo: IN STD_LOGIC_VECTOR (31 downto 0);             --32bit ִ�н׶ε�ָ��Ҫд��LO�Ĵ�����ֵ
    ex_whilo: IN STD_LOGIC;                               --1bit  ִ�н׶ε�ָ���Ƿ�ҪдHI��LO�Ĵ���
    ex_aluop: IN STD_LOGIC_VECTOR (7 downto 0);           --8bit  ִ�н׶ε�ָ��Ҫ���е�������������
    ex_mem_addr: IN STD_LOGIC_VECTOR (31 downto 0);       --32bit ִ�н׶εļ��ء��洢ָ����Ӧ�Ĵ洢����ַ
    ex_reg2: IN STD_LOGIC_VECTOR (31 downto 0);           --32bit ִ�н׶εĴ洢ָ��Ҫ�洢������
    ex_cp0_reg_we: IN STD_LOGIC;
    ex_cp0_reg_write_addr: IN STD_LOGIC_VECTOR (4 downto 0);
    ex_cp0_reg_data: IN STD_LOGIC_VECTOR (31 downto 0);
    stall: IN STD_LOGIC_VECTOR(5 downto 0);
    flush: IN STD_LOGIC;
    ex_excepttype: IN STD_LOGIC_VECTOR(31 downto 0);
    ex_current_inst_addr: IN STD_LOGIC_VECTOR(31 downto 0);
    ex_is_in_delayslot: IN STD_LOGIC;

    mem_wd: BUFFER STD_LOGIC_VECTOR (4 downto 0);         --5bit  �ô��׶ε�ָ��Ҫд��Ŀ�ļĴ�����ֵ
    mem_wreg: BUFFER STD_LOGIC;                           --1bit  �ô��׶ε�ָ���Ƿ���Ҫд����Ŀ�ļĴ���
    mem_wdata: BUFFER STD_LOGIC_VECTOR (31 downto 0);     --32bit �ô��׶ε�ָ��Ҫд��Ŀ�ļĴ�����ֵ
    mem_hi: OUT STD_LOGIC_VECTOR (31 downto 0);           --32bit �ô��׶ε�ָ��Ҫд��HI�Ĵ�����ֵ
    mem_lo: OUT STD_LOGIC_VECTOR (31 downto 0);           --32bit �ô��׶ε�ָ��Ҫд��LO�Ĵ�����ֵ
    mem_whilo: OUT STD_LOGIC;                             --1bit  �ô��׶ε�ָ���Ƿ�Ҫд��HI��LO�Ĵ���
    mem_aluop: OUT STD_LOGIC_VECTOR (7 downto 0);         --8bit  �ô��׶ε�ָ��Ҫ����������������
    mem_mem_addr: OUT STD_LOGIC_VECTOR (31 downto 0);     --32bit �ô��׶εļ��ء��洢ָ����Ӧ�Ĵ洢����ַ
    mem_reg2: OUT STD_LOGIC_VECTOR (31 downto 0);         --32bit �ô��׶εĴ洢ָ��Ҫ�洢������
    mem_cp0_reg_we: OUT STD_LOGIC;
    mem_cp0_reg_write_addr: OUT STD_LOGIC_VECTOR (4 downto 0);
    mem_cp0_reg_data: OUT STD_LOGIC_VECTOR (31 downto 0);
    mem_excepttype: OUT STD_LOGIC_VECTOR(31 downto 0);
    mem_current_inst_addr: OUT STD_LOGIC_VECTOR(31 downto 0);
    mem_is_in_delayslot: OUT STD_LOGIC
  );
end ex_mem;

  ARCHITECTURE behave OF ex_mem IS

  BEGIN
    PROCESS(clk, rst, stall)
      BEGIN
		if (clk'event and clk = '1') then                    --ʱ��������
          if (rst = '0') then
            mem_wd <= "00000";
            mem_wreg <= '0';
            mem_wdata <= X"00000000";
            mem_hi <= X"00000000";
            mem_lo <= X"00000000";
            mem_whilo <= '0';
				    mem_aluop <= "00000000";
				    mem_mem_addr <= X"00000000";
				    mem_reg2 <= X"00000000";
            mem_cp0_reg_we <= '0';
            mem_cp0_reg_write_addr <= "00000";
            mem_cp0_reg_data <= X"00000000";
            mem_excepttype <= X"00000000";
            mem_is_in_delayslot <= '0';
            mem_current_inst_addr <= X"00000000";

          elsif (flush = '1') then
            mem_wd <= "00000";
            mem_wreg <= '0';
            mem_wdata <= X"00000000";
            mem_hi <= X"00000000";
            mem_lo <= X"00000000";
            mem_whilo <= '0';
            mem_aluop <= EXE_NOP_OP;
            mem_mem_addr <= X"00000000";
            mem_reg2 <= X"00000000";
            mem_cp0_reg_we <= '0';
            mem_cp0_reg_write_addr <= "00000";
            mem_cp0_reg_data <= X"00000000";
            mem_excepttype <= X"00000000";
            mem_is_in_delayslot <= '0';
            mem_current_inst_addr <= X"00000000";


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
				    mem_cp0_reg_we <= '0';
            mem_cp0_reg_write_addr <= "00000";
            mem_cp0_reg_data <= X"00000000";
            mem_excepttype <= X"00000000";
            mem_is_in_delayslot <= '0';
            mem_current_inst_addr <= X"00000000";

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
            mem_cp0_reg_we <= ex_cp0_reg_we;
            mem_cp0_reg_write_addr <= ex_cp0_reg_write_addr;
            mem_cp0_reg_data <= ex_cp0_reg_data;
            mem_excepttype <= ex_excepttype;
            mem_is_in_delayslot <= ex_is_in_delayslot;
            mem_current_inst_addr <= ex_current_inst_addr;
          END IF;
        END IF;
      END PROCESS;
    END;
