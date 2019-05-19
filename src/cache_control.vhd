library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity cache_control is
	port(
		clk, wren	: in  std_logic;
		address_cache		: out  std_logic_vector(4 downto 0);
		address_ram		: in  std_logic_vector(15 downto 0);
		
		
		stall_cache	: out  std_logic;
		read_hit, read_miss	: out  std_logic;
		write_hit, write_miss	: out  std_logic
	);
end entity cache_control;

architecture cache_control_arch of cache_control is

component cache_table is
	port(
		clk, wren            : in  std_logic;
		address              : in  std_logic_vector(2 downto 0); -- line number
		dirty_in, validate   : in  std_logic;
		tag_in               : in  std_logic_vector(9 downto 0);
		dirty_out, valid_out : out std_logic;
		tag_out              : out std_logic_vector(9 downto 0)
	);
end component cache_table;

begin


end architecture cache_control_arch;
