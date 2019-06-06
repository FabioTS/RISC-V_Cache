library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity data_cache_tb is
end entity data_cache_tb;

architecture RTL of data_cache_tb is

	constant clk_period : time      := 20 ps;
	signal clk          : std_logic := '1';
	signal clk_unset    : std_logic := '0';
	
	signal test_output  : std_logic_vector(31 downto 0);
	
	signal address        : std_logic_vector(31 downto 0) := (others => '0');
	signal byteena        : std_logic_vector(3 downto 0)  := "1111";
	signal data           : std_logic_vector(31 downto 0) := (others => '0');
	signal wren           : std_logic                     := '0';
	signal q              : std_logic_vector(31 downto 0) := (others => '0');
	signal stall_cache    : std_logic;
	signal read_hit       : std_logic;
	signal read_miss      : std_logic;
	signal write_hit      : std_logic;
	signal write_miss     : std_logic;
	signal write_back     : std_logic;
	signal reset, advance : std_logic                     := '0';
	
	signal data_blk_in  : std_logic_vector(127 downto 0);
	signal hold_ram     : std_logic;
	signal ready_ram    : std_logic;
	signal address_ram  : std_logic_vector(15 downto 0);
	signal data_blk_out : std_logic_vector(127 downto 0);
	signal wren_ram     : std_logic;
	signal read_ram     : std_logic;

begin

	clk <= not clk after clk_period / 2 when clk_unset = '0' else '0';

	reset <= '1' when advance = '1' else '0';

	DUT : entity work.data_cache
		port map(
			clk          => clk,
			wren         => wren,
			address      => address,
			byteena      => byteena,
			data         => data,
			q            => q,
			stall_cache  => stall_cache,
			read_hit     => read_hit,
			read_miss    => read_miss,
			write_hit    => write_hit,
			write_miss   => write_miss,
			write_back   => write_back,
			address_ram  => address_ram,
			data_blk_out => data_blk_out,
			wren_ram     => wren_ram,
			data_blk_in  => data_blk_in,
			read_ram     => read_ram,
			hold_ram     => hold_ram,
			ready_ram    => ready_ram
		);

	ram_inst : entity work.ram2
		port map(
			address => address_ram,
			clock   => clk,
			data    => data_blk_out,
			wren    => wren_ram,
			q       => data_blk_in,
			read    => read_ram,
			hold    => hold_ram,
			ready   => ready_ram
		);

	process(clk) is
	begin
		if rising_edge(clk) and stall_cache /= '1' then
			test_output <= q;
		end if;

	end process;

	process
	begin
		-- RM
		wren    <= '0';
		address <= ("000000000000000000000000000" & "111" & "00");
		wait until rising_edge(clk) and stall_cache = '0';
		
		-- WH
		data    <= (x"00ABCDEF");
		wren    <= '1';
		address <= ("000000000000000000000000000" & "111" & "01");
		wait until rising_edge(clk) and stall_cache = '0';
		assert (test_output = x"0004D973");
		-- WB RM
		wren    <= '0';
		address <= ("000000000000000000000000001" & "111" & "00");
		wait until rising_edge(clk) and stall_cache = '0';
		-- RM
		wren    <= '0';
		address <= ("000000000000000000000000000" & "111" & "01");
		wait until rising_edge(clk) and stall_cache = '0';
		assert (test_output = x"00000090");

		-- READ MISS TEST
		wren    <= '0';
		address <= ("000000000000000000000000000" & "000" & "01");
		wait until rising_edge(clk) and stall_cache = '0';
		assert (test_output = x"00ABCDEF");
		
		address <= ("000000000000000000000000000" & "000" & "11");
		wait until rising_edge(clk) and stall_cache = '0';
		assert (test_output = x"00000001");
		
		address <= ("000000000000000000000000000" & "001" & "00");
		wait until rising_edge(clk) and stall_cache = '0';
		assert (test_output = x"00000002");
		
		address <= ("000000000000000000000000001" & "000" & "01");
		wait until rising_edge(clk) and stall_cache = '0';
		assert (test_output = x"00000003");
		
		address <= ("000000000000000000000000001" & "011" & "11");
		wait until rising_edge(clk) and stall_cache = '0';
		assert (test_output = x"00000001");
		
		address <= ("000000000000000000000000000" & "001" & "01");
		wait until rising_edge(clk) and stall_cache = '0';
		assert (test_output = x"B11924E1");
		
		wait until rising_edge(clk) and stall_cache = '0';
		assert (test_output = x"00000005");

		-- WRITE MISS TEST
		wren    <= '1';
		address <= ("000000000000000000000000000" & "000" & "01");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000000" & "000" & "11");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000000" & "001" & "00");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000001" & "000" & "10");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000000" & "000" & "10");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000001" & "011" & "11");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000000" & "001" & "01");
		wait until rising_edge(clk) and stall_cache = '0';

		clk_unset <= '1' after 1 ns;
		wait;
	end process;

end architecture RTL;
