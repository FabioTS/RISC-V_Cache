library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity stage_EX is
	generic(WSIZE : natural);

	port(
		clk                                               : in  std_logic;
		instruction_in                                    : in  std_logic_vector((WSIZE - 1) downto 0);
		instruction_out                                   : out std_logic_vector((WSIZE - 1) downto 0);
		wdata_in                                          : in  std_logic_vector((WSIZE - 1) downto 0);
		wdata_out                                         : out std_logic_vector((WSIZE - 1) downto 0);
		ALU_A, ALU_B                                      : in  std_logic_vector((WSIZE - 1) downto 0);
		ALU_Z                                             : out std_logic_vector((WSIZE - 1) downto 0);
		wren_memory_in, wren_register_in, WB_select_in    : in  std_logic;
		wren_memory_out, wren_register_out, WB_select_out : out std_logic;
		stall_stages                                      : in  std_logic
	);
end entity stage_EX;

architecture stage_EX_arch of stage_EX is
	--	signal zero         : std_logic;
	signal Z            : std_logic_vector((WSIZE - 1) downto 0);
	signal ALU_function : FUNCTION_TYPE;

begin

	ALU_control : entity work.ALU_control
		generic map(
			WSIZE => WSIZE
		)
		port map(
			instruction  => instruction_in,
			ALU_function => ALU_function
		);

	ALU : entity work.ALU
		generic map(
			WSIZE => WSIZE
		)
		port map(
			ALU_function => ALU_function,
			shamt        => instruction_in(24 downto 20),
			A            => ALU_A,
			B            => ALU_B,
			Z            => Z,
			zero         => open
		);

	process(clk) is
	begin
		if rising_edge(clk) then
			if stall_stages /= '1' then
				instruction_out   <= instruction_in;
				wdata_out         <= wdata_in;
				wren_memory_out   <= wren_memory_in;
				wren_register_out <= wren_register_in;
				WB_select_out     <= WB_select_in;
				ALU_Z             <= Z;
			end if;
		end if;
	end process;

end architecture stage_EX_arch;
