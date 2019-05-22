library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity cache_control is
	port(
		clk, wren, ready_ram  : in  std_logic;
		address               : in  std_logic_vector(31 downto 0);
		wren_blk, wren_ram    : out std_logic;
		read_ram, stall_cache : out std_logic;
		read_hit, read_miss   : out std_logic;
		write_hit, write_miss : out std_logic
	);
end entity cache_control;

architecture RTL of cache_control is

	-- Build an enumerated type for the state machine
	type state_type is (rh, rm, wh, wm);

	-- Register to hold the current state
	signal state : state_type := rm;

	signal modified, validate : std_logic := '0';
	signal dirty, valid       : std_logic;
	signal wren_table         : std_logic := '0';
	signal tag                : std_logic_vector(26 downto 0);

	alias line_number : std_logic_vector(2 downto 0) is address(4 downto 2);
	alias tag_in      : std_logic_vector(26 downto 0) is address(31 downto 5);

begin

	cache_table_inst : entity work.cache_table
		port map(
			clk       => clk,
			wren      => wren_table,
			address   => line_number,
			dirty_in  => modified,
			validate  => validate,
			tag_in    => tag_in,
			dirty_out => dirty,
			valid_out => valid,
			tag_out   => tag
		);

	--	state <= rh when (wren = '0' and (valid = '1' and tag = address(31 downto 5)))
	--		else rm when (wren = '0' and (valid = '0' or tag /= address(31 downto 5)))
	--		else wh when (wren = '1' and (valid = '1' and tag = address(31 downto 5)))
	--		else wm when (wren = '1' and (valid = '0' or tag /= address(31 downto 5)))
	--		else rm;

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

	with state select stall_cache <=
		'0' when rh,
		'0' when wh,
		'1' when others;

	-- Logic to advance to the next state
	process(clk)
	begin
		if (rising_edge(clk)) then
			--			case state is
			--				when rh =>
			--					if (wren = '0' and (valid = '1' and tag = tag_in)) then
			--						state <= rh;
			--					end if;
			--				when rm =>
			--					if (wren = '0' and (valid = '0' or tag /= tag_in)) then
			--						state <= rm;
			--					end if;
			--				when wh =>
			--					if (wren = '1' and (valid = '1' and tag = tag_in)) then
			--						state <= wh;
			--					end if;
			--				when wm =>
			--					if (wren = '1' and (valid = '0' or tag /= tag_in)) then
			--						state <= wm;
			--					end if;
			--				when others =>
			--					state <= rm;
			--			end case;

			if (wren = '0' and (valid = '1' and tag = tag_in)) then
				state <= rh;
			elsif (wren = '0' and (valid = '0' or tag /= tag_in)) then
				state <= rm;
			elsif (wren = '1' and (valid = '1' and tag = tag_in)) then
				state <= wh;
			elsif (wren = '1' and (valid = '0' or tag /= tag_in)) then
				if ready_ram = '1' then
					state <= wh;
				else
					state <= wm;
				end if;
			else
				state <= rh;
			end if;
		end if;
	end process;

	-- Output depends solely on the current state
	process(state)
	begin
		case state is
			when rm =>                  -- wait until ready_ram = '1';	-- Delay of 7 cycles (Altera AVALLON)
			-- TODO: Write to ram if dirty
				modified   <= '0';
				validate   <= '1';
				wren_table <= '1';
				wren_blk   <= '1';
				read_ram   <= '1';

			when wh =>                  -- TODO: Write back policie
				modified   <= '1';
				validate   <= '0';
				wren_table <= '1';
				wren_blk   <= '0';
				read_ram   <= '0';

			when wm =>                  -- Write allocate policie
			--				wait until ready_ram = '1';	-- Delay of 7 cycles (Altera AVALLON)
				modified   <= '0';
				validate   <= '1';
				wren_table <= '1';
				wren_blk   <= '1';
				read_ram   <= '1';

			when others =>
				modified   <= '0';
				validate   <= '0';
				wren_table <= '0';
				wren_blk   <= '0';
				read_ram   <= '0';
		end case;
	end process;

end architecture RTL;
