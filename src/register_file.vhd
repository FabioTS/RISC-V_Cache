library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
	generic(WSIZE : natural);

	port(
		clk, write_enable : in  std_logic;
		rs1, rs2, rd      : in  std_logic_vector(4 downto 0);
		write_data        : in  std_logic_vector(WSIZE - 1 downto 0);
		r1, r2            : out std_logic_vector(WSIZE - 1 downto 0)
	);
end entity register_file;

architecture register_file_arch of register_file is

	TYPE ARRAY_32X32 is array (0 to WSIZE - 1) of std_logic_vector(WSIZE - 1 downto 0);
	signal registers : ARRAY_32X32 := ((others => (others => '0')));

begin

	process(clk) is
		variable i : natural;

	begin
		if (rising_edge(clk)) then
			if (write_enable = '1') then
				i := to_integer(unsigned(rd));
				if (i /= 0) then
					registers(i) <= write_data;
				end if;
			end if;
			r1 <= registers(to_integer(unsigned(rs1)));
			r2 <= registers(to_integer(unsigned(rs2)));
		end if;

	end process;

end architecture register_file_arch;