library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity cache_table is
	port(
		clk, wren            : in  std_logic;
		address              : in  std_logic_vector(2 downto 0); -- line number
		dirty_in, validate   : in  std_logic;
		tag_in               : in  std_logic_vector(9 downto 0);
		dirty_out, valid_out : out std_logic;
		tag_out              : out std_logic_vector(9 downto 0)
	);
end entity cache_table;

architecture cache_table_arch of cache_table is

	type bit_array is array (2 downto 0) of std_logic;
	type tag_array is array (2 downto 0) of std_logic_vector(9 downto 0);

	signal dirty_table : bit_array := (others => '0');
	signal valid_table : bit_array := (others => '0');
	signal tag_table   : tag_array;

begin
	dirty_out <= dirty_table(to_integer(unsigned(address)));
	valid_out <= valid_table(to_integer(unsigned(address)));
	tag_out   <= tag_table(to_integer(unsigned(address)));

	process(clk) is
	begin
		if (rising_edge(clk) and (wren = '1')) then
			if (dirty_in = '1') then    -- Set line as modified
				dirty_table(to_integer(unsigned(address))) <= '1';
			end if;
			if (validate = '1') then    -- validate line when read from memory ram
				valid_table(to_integer(unsigned(address))) <= '1';
			end if;

			tag_table(to_integer(unsigned(address))) <= tag_in; -- if wren then write new tag of addressess
		end if;

	end process;

end architecture cache_table_arch;
