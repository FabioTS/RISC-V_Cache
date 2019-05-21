library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity cache_memory is
	port(
		clk, wren : in    std_logic;
		address   : in    std_logic_vector(4 downto 0);
		byteena    : in    std_logic_vector(3 downto 0);
		data      : in    std_logic_vector(WORD_SIZE - 1 downto 0);
		q         : out   std_logic_vector(WORD_SIZE - 1 downto 0);
		wren_blk  : in    std_logic;
		data_blk  : inout std_logic_vector((WORD_SIZE * BLK_SIZE) - 1 downto 0)
	);
end entity cache_memory;

architecture RTL of cache_memory is

	type cache_block_array is array (BLK_SIZE - 1 downto 0) of std_logic_vector(WORD_SIZE - 1 downto 0);
	type cache_lines_array is array (N_BLK - 1 downto 0) of cache_block_array;
	signal cache_mem : cache_lines_array; -- := ((others => (others => '0')));
	
	signal data_blk_resolved : cache_block_array;

	alias blk        : std_logic_vector (2 downto 0) is address(4 downto 2);
	alias blk_offset : std_logic_vector (1 downto 0) is address(1 downto 0);

begin
	q <= cache_mem(to_integer(unsigned(blk)))(to_integer(unsigned(blk_offset)));

	data_blk_resolved(3) <= data_blk(127 downto 96);
	data_blk_resolved(2) <= data_blk(95 downto 64);
	data_blk_resolved(1) <= data_blk(63 downto 32);
	data_blk_resolved(0) <= data_blk(31 downto 0);
	
	process(clk) is
	begin
--		if (falling_edge(clk)) then
			if (wren_blk = '1') then
				cache_mem(to_integer(unsigned(blk))) <= data_blk_resolved;
			elsif (wren = '1') then
				cache_mem(to_integer(unsigned(blk)))(to_integer(unsigned(blk_offset))) <= data;
			end if;
--		end if;

	end process;

end architecture RTL;
