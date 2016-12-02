signal memory: mem_array;
signal mem_address: std_logic_vector(31 downto 0);
signal mem_data: std_logic_vector(31 downto 0);
signal mem_read: std_logic;
signal mem_write: std_logic;

cpu_mem_data <= transport memory(to_integer(unsigned(mem_address))) after DELAY when mem_read = '1' else (others => 'Z');

process
    file in_file: text open read_mode is "in.txt";
    variable line_str: line;
    variable address: std_logic_vector(31 downto 0);
    variable data: std_logic_vector(31 downto 0);
begin
    -- Initialize memory by reading file
    reset <= '1';

    readline(in_file, line_str);
    hread(line_str, address);
    starting_pc <= address;
    while not endfile(in_file) loop
        readline(in_file, line_str);
        hread(line_str, address);
        read(line_str, data);
        memory(to_integer(unsigned(address))) <= data;
        report "Initialized " & integer'image(to_integer(unsigned(address))) & " to " & 
              integer'image(to_integer(unsigned(data)));
    end loop;

    wait for 30 ns;

    reset <= '0';

    -- Write to Memory
    Write_loop : loop 
        wait until rising_edge(mem_write) ;
        memory(to_integer(unsigned(mem_address))) <= transport mem_data after DELAY;
    end loop ;
end process ; 