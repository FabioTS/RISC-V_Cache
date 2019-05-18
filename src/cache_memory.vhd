library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity cache_memory is
	port(
		clk, wren	: in  std_logic;
		addr		: in  std_logic_vector(4 downto 0);
		wrdata      : in  std_logic_vector(WORD_SIZE - 1 downto 0);
		data        : out std_logic_vector(WORD_SIZE - 1 downto 0)
	);
end entity cache_memory;

architecture cache_memory_arch of cache_memory is

	type cache_block_array is array (BLK_SIZE-1 downto 0) of std_logic_vector (WORD_SIZE - 1 downto 0); 
	type cache_lines_array is array (N_BLK-1 downto 0) of cache_block_array;
    signal cache_mem : cache_lines_array; -- := ((others => (others => '0')));
    
    alias blk 			: std_logic_vector (2 downto 0) is addr(4 downto 2);
    alias blk_offset 	: std_logic_vector (1 downto 0) is addr(1 downto 0);

begin
	data <= cache_mem(to_integer(unsigned(blk)))(to_integer(unsigned(blk_offset)));

	process(clk) is
		
	begin
--		if (falling_edge(clk)) then
			if (wren = '1') then
				cache_mem(to_integer(unsigned(blk)))(to_integer(unsigned(blk_offset))) <= wrdata;
			end if;
--		end if;

	end process;

end architecture cache_memory_arch;
