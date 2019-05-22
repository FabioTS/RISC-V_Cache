library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity cache is
	port(
		clk, wren             : in  std_logic;
		address               : in  std_logic_vector(31 downto 0);
		byteena               : in  std_logic_vector(3 downto 0);
		data                  : in  std_logic_vector(WORD_SIZE - 1 downto 0);
		q                     : out std_logic_vector(WORD_SIZE - 1 downto 0);
		stall_cache           : out std_logic;
		read_hit, read_miss   : out std_logic;
		write_hit, write_miss : out std_logic
	);
end entity cache;

architecture RTL of cache is

	signal wren_blk, wren_ram, ready_ram, read_ram : std_logic := '0';
	signal data_blk, ram_in, ram_out     : std_logic_vector((WORD_SIZE * BLK_SIZE) - 1 downto 0); -- INOUT
	signal reset_delay : std_logic;

begin

	ram_inst : entity work.ram
		port map(
			address => address(15 downto 0),
			clock   => clk,
			data    => ram_in,
			wren    => wren_ram,
			q       => ram_out
		);

	memory_inst : entity work.cache_memory
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

	control_inst : entity work.cache_control
		port map(
			clk         => clk,
			wren        => wren,
			ready_ram   => ready_ram,
			address     => address,
			wren_blk    => wren_blk,
			wren_ram    => wren_ram,
			read_ram    => read_ram,
			stall_cache => stall_cache,
			read_hit    => read_hit,
			read_miss   => read_miss,
			write_hit   => write_hit,
			write_miss  => write_miss
		);

	delay_inst : entity work.binary_counter
		generic map(
			MIN_COUNT => 0,
			MAX_COUNT => 7
		)
		port map(
			clk    => clk,
			reset  => reset_delay,
			enable => read_ram,
			max    => ready_ram,
			q      => open
		);
		
		reset_delay <= '1' when read_ram = '0' else '0';

end architecture RTL;
