library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram2 is
	port(
		address     : in  std_logic_vector(15 downto 0);
		clock       : in  std_logic := '1';
		data        : in  std_logic_vector(127 downto 0);
		wren        : in  std_logic;
		q           : out std_logic_vector(127 downto 0);
		read        : in  std_logic;
		hold, ready : out std_logic
	);
end entity ram2;

architecture RTL of ram2 is
	signal reset : std_logic;

begin

	ram_inst : entity work.ram
		port map(
			address => address,
			clock   => clock,
			data    => data,
			wren    => wren,
			q       => q
		);

	delay_inst : entity work.binary_counter
		generic map(
			MIN_COUNT => 0,
			MAX_COUNT => 2              -- Delay of 7 cycles (Altera AVALLON)
		)
		port map(
			clk    => clock,
			reset  => reset,
			enable => read,
			max    => ready,
			q      => open
		);

	hold <= '1' when (read = '1' and ready /= '1') else '0';

	reset <= not hold;

end architecture RTL;
