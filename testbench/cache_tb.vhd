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
	signal wren        : std_logic;
	signal q           : std_logic_vector(31 downto 0) := (others => '0');
	signal wren_blk    : std_logic;
	signal data_blk    : std_logic_vector((WORD_SIZE * BLK_SIZE) - 1 downto 0) := (others => '0');
	signal ready_ram   : std_logic;
	signal wren_ram    : std_logic;
	signal stall_cache : std_logic;
	signal read_hit    : std_logic;
	signal read_miss   : std_logic;
	signal write_hit   : std_logic;
	signal write_miss  : std_logic;

begin

	clk <= not clk after clk_period / 2 when clk_unset = '0' else '0';

	inst0 : entity work.ram
		port map(
			address => address(15 downto 0),
			byteena => byteena,
			clock   => clk,
			data    => data,
			wren    => wren,
			q       => q
		);

	inst1 : entity work.cache_memory
		port map(
			clk      => clk,
			wren     => wren,
			address  => address(4 downto 0),
			byteena  => byteena,
			data     => data,
			q        => q,
			wren_blk => wren_blk,
			data_blk => data_blk
		);

	inst2 : entity work.cache_control
		port map(
			clk         => clk,
			wren        => wren,
			ready_ram   => ready_ram,
			address     => address,
			wren_blk    => wren_blk,
			wren_ram    => wren_ram,
			stall_cache => stall_cache,
			read_hit    => read_hit,
			read_miss   => read_miss,
			write_hit   => write_hit,
			write_miss  => write_miss
		);

	tb : process
	begin
		-- READ MISS TEST
		address <= std_logic_vector(to_unsigned(1, WORD_SIZE));
--		wait until stall_cache = '0';
		wait for 100 ps;

		clk_unset <= '1' after 1000 ps;
		wait;
	end process;

end architecture RTL;
