library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity stage_IF is
	generic(WSIZE : natural);

	port(
		clk                           : in  std_logic;
		immediate, rs1                : in  std_logic_vector((WSIZE - 1) downto 0);
		next_pc_select                : in  std_logic_vector(1 downto 0);
		stall                         : in  std_logic;
		instruction_out, PC_IF_ID_out : out std_logic_vector((WSIZE - 1) downto 0)
	);
end stage_IF;

architecture stage_IF_arch of stage_IF is
	signal current_pc, next_pc, pc_plus_4, PC_IF_ID : std_logic_vector((WSIZE - 1) downto 0);
	signal jalr_result0, jal_result, jalr_result    : std_logic_vector((WSIZE - 1) downto 0);
	signal current_instruction                      : std_logic_vector((WSIZE - 1) downto 0);
	signal clk_memory                                : std_logic;

begin
	PC_IF_ID_out <= PC_IF_ID;
	clk_memory   <= (not clk) and (not stall);
	jalr_result0 <= jalr_result((WSIZE - 1) downto 1) & '0';

	PC : entity work.PC
		generic map(WSIZE => WSIZE)
		port map(
			clk        => clk,
			stall      => stall,
			next_pc    => next_pc,
			current_pc => current_pc
		);

	adder : entity work.adder
		generic map(WSIZE => WSIZE)
		port map(
			a      => current_pc,
			b      => std_logic_vector(to_unsigned(4, WSIZE)),
			result => pc_plus_4
		);

	adder_imm : entity work.adder
		generic map(
			WSIZE => WSIZE
		)
		port map(
			a      => PC_IF_ID,
			b      => immediate,
			result => jal_result
		);

	adder_jalr : entity work.adder
		generic map(
			WSIZE => WSIZE
		)
		port map(
			a      => rs1,
			b      => immediate,
			result => jalr_result
		);

	mux4 : entity work.mux4
		generic map(WSIZE => WSIZE)
		port map(
			S  => next_pc_select,
			I0 => pc_plus_4,
			I1 => jal_result,
			I2 => jalr_result0,
			I3 => (others => '0'),      --TODO
			O  => next_pc
		);

	instruction_memory : entity work.instruction_memory
		port map(
			address => current_pc(9 downto 2),
			clock   => clk_memory,
			q       => current_instruction
		);

	process(clk) is
	begin
		if rising_edge(clk) then
			if next_pc_select = PC_SELECT_PLUS4 then
				instruction_out <= current_instruction;
			else
				instruction_out <= BUBBLE;
			end if;

			PC_IF_ID <= current_pc;
		end if;
	end process;

end stage_IF_arch;
