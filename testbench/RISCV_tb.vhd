LIBRARY ieee;
USE ieee.std_logic_1164.all;

use work.constants.all;

ENTITY RISCV_tb IS

END RISCV_tb;

ARCHITECTURE RISCV_tb_arch OF RISCV_tb IS
	constant clk_period    : time                                     := 20 ps;
	signal clk             : std_logic                                := '1';
	signal clk_unset       : std_logic                                := '0';
	signal instruction     : std_logic_vector(WORD_SIZE - 1 downto 0) := (others => '0');
	signal registers_array : ARRAY_32X32;

BEGIN
	riscv : entity work.RISCV
		port map(
			clk             => clk,
			instruction     => instruction,
			registers_array => registers_array
		);

	clk <= not clk after clk_period / 2 when clk_unset = '0' else '0';
	always : PROCESS
	BEGIN
		clk_unset <= '1' after 5 ns;
		wait;
	END PROCESS always;
END RISCV_tb_arch;
