library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;
use work.ram2;

entity data_cache is
	port(
		clk, wren             : in  std_logic;
		address               : in  std_logic_vector(31 downto 0);
		byteena               : in  std_logic_vector(3 downto 0);
		data                  : in  std_logic_vector(WORD_SIZE - 1 downto 0);
		q                     : out std_logic_vector(WORD_SIZE - 1 downto 0);
		stall_cache           : out std_logic;
		read_hit, read_miss   : out std_logic;
		write_hit, write_miss : out std_logic;
		write_back            : out std_logic;
		
		address_ram           : out std_logic_vector(RAM_ADDRESS_SIZE-1 downto 0) := (others => '0');
		data_blk_out          : out std_logic_vector((WORD_SIZE*BLK_SIZE)-1 downto 0);
		wren_ram              : out std_logic;
		data_blk_in           : in  std_logic_vector((WORD_SIZE*BLK_SIZE)-1 downto 0);
		read_ram              : out std_logic;
		hold_ram, ready_ram   : in  std_logic
	);
end entity data_cache;

architecture RTL of data_cache is

	signal wren_blk, wren_cache : std_logic := '0';
	signal tag_out              : std_logic_vector(31 - (LOG2_BLK_SIZE + LOG2_N_BLK) downto 0);

	alias blk        : std_logic_vector (LOG2_N_BLK - 1 downto 0) is address((LOG2_N_BLK + LOG2_BLK_SIZE)-1 downto LOG2_BLK_SIZE);
	alias blk_offset : std_logic_vector (LOG2_BLK_SIZE - 1 downto 0) is address(LOG2_BLK_SIZE - 1 downto 0);

begin
	-- If in write back state, the address to write on ram must be the one stored in tag table
	address_ram <= (tag_out((address_ram'length - LOG2_N_BLK)-1 downto 0) & blk) when write_back = '1' else address((address_ram'length + LOG2_BLK_SIZE)-1 downto LOG2_BLK_SIZE);

--	ram_inst : entity work.ram2
--		port map(
--			address => address_ram,
--			clock   => clk,
--			data    => data_blk_out,
--			wren    => wren_ram,
--			q       => data_blk_in,
--			read    => read_ram,
--			hold    => hold_ram,
--			ready   => ready_ram
--		);

	memory_inst : entity work.cache_memory
		port map(
			clk          => clk,
			wren         => wren_cache,
			address      => address((LOG2_BLK_SIZE + LOG2_N_BLK)-1 downto 0),
			byteena      => byteena,
			data         => data,
			q            => q,
			wren_blk     => wren_blk,
			data_blk_in  => data_blk_in,
			data_blk_out => data_blk_out
		);

	control_inst : entity work.cache_control
		port map(
			clk         => clk,
			wren        => wren,
			ready_ram   => ready_ram,
			address     => address,
			wren_blk    => wren_blk,
			wren_cache  => wren_cache,
			wren_ram    => wren_ram,
			hold_ram    => hold_ram,
			tag_out     => tag_out,
			read_ram    => read_ram,
			stall_cache => stall_cache,
			read_hit    => read_hit,
			read_miss   => read_miss,
			write_hit   => write_hit,
			write_miss  => write_miss,
			write_back  => write_back
		);

end architecture RTL;
