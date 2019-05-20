library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity cache_control is
	port(
		clk, wren             : in  std_logic;
		address               : in  std_logic_vector(31 downto 0);
		stall_cache           : out std_logic;
		read_hit, read_miss   : out std_logic;
		write_hit, write_miss : out std_logic
	);
end entity cache_control;

architecture cache_control_arch of cache_control is

	-- Build an enumerated type for the state machine
	type state_type is (rh, rm, wh, wm);

	-- Register to hold the current state
	signal state : state_type := rm;

begin
	state <= rh when (wren = '0' and (valid = '1' and tag = address(31 downto 5)))
		else rm when (wren = '0' and (valid = '0' or tag /= address(31 downto 5)))
		else wh when (wren = '1' and (valid = '1' and tag = address(31 downto 5)))
		else wm when (wren = '1' and (valid = '0' or tag /= address(31 downto 5)))
		else rm;

	with state select read_hit <=
		'1' when rh,
		'0' when others;
	with state select read_miss <=
		'1' when rm,
		'0' when others;
	with state select write_hit <=
		'1' when wh,
		'0' when others;
	with state select write_miss <=
		'1' when wm,
		'0' when others;

	-- Logic to advance to the next state
	process(clk, reset)
	begin
		if (rising_edge(clk)) then
			case state is
				when rh =>
					stall_cache <= '0';
				when rm =>
					stall_cache <= '1';
				when wh =>
					stall_cache <= '0';
				when wm =>
					stall_cache <= '1';
			end case;
		end if;
	end process;

end architecture cache_control_arch;
