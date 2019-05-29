library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity cache_tb is
end entity cache_tb;

architecture RTL of cache_tb is

	constant clk_period : time      := 20 ps;
	signal clk          : std_logic := '1';
	signal clk_unset    : std_logic := '0';

	signal address     : std_logic_vector(31 downto 0) := (others => '0');
	signal byteena     : std_logic_vector(3 downto 0) := "1111";
	signal data        : std_logic_vector(31 downto 0) := (others => '0');
	signal wren        : std_logic := '0';
	signal q           : std_logic_vector(31 downto 0) := (others => '0');
	signal stall_cache : std_logic;
	signal read_hit    : std_logic;
	signal read_miss   : std_logic;
	signal write_hit   : std_logic;
	signal write_miss  : std_logic;
	signal reset, advance : std_logic := '0';

	signal test_output : std_logic_vector(31 downto 0);

begin

	clk <= not clk after clk_period / 2 when clk_unset = '0' else '0';
	
	reset <= '1' when advance = '1' else '0';

	DUT : entity work.cache
		port map(
			clk         => clk,
			wren        => wren,
			address     => address,
			byteena     => byteena,
			data        => data,
			q           => q,
			stall_cache => stall_cache,
			read_hit    => read_hit,
			read_miss   => read_miss,
			write_hit   => write_hit,
			write_miss  => write_miss
		);
		
	process (clk) is
	begin
		if rising_edge(clk) and stall_cache /= '1' then
			test_output <= q;
		end if;
		
	end process ;
	
	process
	begin
		-- RM
		wren <= '0';
		address <= ("000000000000000000000000000" & "111" & "00");
		wait until rising_edge(clk) and stall_cache = '0';
		-- WH
		data <= std_logic_vector(to_unsigned(128, WORD_SIZE));
		wren <= '1';
		address <= ("000000000000000000000000000" & "111" & "01");
		wait until rising_edge(clk) and stall_cache = '0';
		-- WB RM
		wren <= '0';
		address <= ("000000000000000000000000001" & "111" & "00");
		wait until rising_edge(clk) and stall_cache = '0';
		-- RM
		wren <= '0';
		address <= ("000000000000000000000000001" & "111" & "00");
		wait until rising_edge(clk) and stall_cache = '0';
		
		-- READ MISS TEST
		wren <= '0';
		address <= ("000000000000000000000000000" & "000" & "01");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000000" & "000" & "11");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000000" & "001" & "00");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000001" & "000" & "01");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000001" & "011" & "11");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000000" & "001" & "01");
		wait until rising_edge(clk) and stall_cache = '0';
		
		-- WRITE MISS TEST
		wren <= '1';
		address <= ("000000000000000000000000000" & "000" & "01");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000000" & "000" & "11");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000000" & "001" & "00");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000001" & "000" & "01");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000001" & "011" & "11");
		wait until rising_edge(clk) and stall_cache = '0';
		address <= ("000000000000000000000000000" & "001" & "01");
		wait until rising_edge(clk) and stall_cache = '0';


		clk_unset <= '1' after 1 ns;
		wait;
	end process;

end architecture RTL;
