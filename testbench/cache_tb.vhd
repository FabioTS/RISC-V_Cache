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
		
	counter: entity work.binary_counter
		generic map(
			MIN_COUNT => 0,
			MAX_COUNT => 10
		)
		port map(
			clk    => clk,
			reset  => reset,
			enable => '1',
			max    => advance,
			q      => open
		);



	process
	begin
		-- READ MISS TEST
		address <= std_logic_vector(to_unsigned(0, WORD_SIZE));
		wait until advance = '1';
		address <= std_logic_vector(to_unsigned(1, WORD_SIZE));
		wait until advance = '1';
		address <= std_logic_vector(to_unsigned(2, WORD_SIZE));
		wait until advance = '1';
		address <= std_logic_vector(to_unsigned(3, WORD_SIZE));
		wait until advance = '1';
		address <= std_logic_vector(to_unsigned(4, WORD_SIZE));
		wait until advance = '1';
		address <= std_logic_vector(to_unsigned(5, WORD_SIZE));
		wait until advance = '1';
		address <= std_logic_vector(to_unsigned(6, WORD_SIZE));
		wait until advance = '1';
		address <= std_logic_vector(to_unsigned(7, WORD_SIZE));
		wait until advance = '1';
		address <= std_logic_vector(to_unsigned(8, WORD_SIZE));
		wait until advance = '1';
		address <= std_logic_vector(to_unsigned(9, WORD_SIZE));
		wait until advance = '1';
		address <= std_logic_vector(to_unsigned(10, WORD_SIZE));
		wait until advance = '1';

		clk_unset <= '1' after 1 ns;
		wait;
	end process;

end architecture RTL;
