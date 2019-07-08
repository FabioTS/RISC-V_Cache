library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity stage_ID is
	generic(WSIZE : natural);

	port(
		clk                                : in  std_logic;
		PC_IF_ID                           : in  std_logic_vector((WSIZE - 1) downto 0);
		instruction_in                     : in  std_logic_vector((WSIZE - 1) downto 0);
		WB_data                            : in  std_logic_vector((WSIZE - 1) downto 0);
		WB_address                         : in  std_logic_vector(4 downto 0);
		wren_register_in                   : in  std_logic;
		wren_memory_out, wren_register_out : out std_logic;
		WB_select_out                      : out std_logic;
		stall_id                              : out std_logic;
		instruction_out                    : out std_logic_vector((WSIZE - 1) downto 0) := (others => '0');
		wdata_out                          : out std_logic_vector((WSIZE - 1) downto 0);
		ALU_A_out, ALU_B_out               : out std_logic_vector((WSIZE - 1) downto 0);
		immediate_out, rs1_out             : out std_logic_vector((WSIZE - 1) downto 0);
		next_pc_select                     : out std_logic_vector(1 downto 0);
		registers_array                    : out ARRAY_32X32;
		
		stall_stages : in std_logic
	);
end entity stage_ID;

architecture stage_ID_arch of stage_ID is
	signal r2, r1, immediate                     : std_logic_vector((WSIZE - 1) downto 0);
	signal wren_memory, wren_register, WB_select : std_logic;
	signal ALUA_select, ALUB_select              : std_logic_vector(1 downto 0);
	signal instruction_type                      : instruction_types;
	signal mux_ALUB_out, mux_ALUA_out            : std_logic_vector((WSIZE - 1) downto 0);
	signal stall_aux                             : std_logic;

	alias rs1    : std_logic_vector(4 downto 0) is instruction_in(19 downto 15);
	alias rs2    : std_logic_vector(4 downto 0) is instruction_in(24 downto 20);
	alias rd     : std_logic_vector(4 downto 0) is instruction_in(11 downto 7);
	alias funct3 : std_logic_vector(2 downto 0) is instruction_in(14 downto 12);
	alias opcode : std_logic_vector(6 downto 0) is instruction_in(6 downto 0);

begin
	immediate_out <= immediate;
	rs1_out       <= r1;
	stall_id         <= stall_aux;

	control : entity work.control
		generic map(
			WSIZE => WSIZE
		)
		port map(
			instruction      => instruction_in,
			instruction_type => instruction_type,
			ALUA_select      => ALUA_select,
			ALUB_select      => ALUB_select,
			wren_memory      => wren_memory,
			wren_register    => wren_register,
			WB_select        => WB_select
		);

	registers : entity work.register_file
		generic map(
			WSIZE => WSIZE
		)
		port map(
			clk             => clk,
			write_enable    => wren_register_in,
			rs1             => rs1,
			rs2             => rs2,
			rd              => WB_address,
			write_data      => WB_data,
			r1              => r1,
			r2              => r2,
			registers_array => registers_array
		);

	imm_decoder : entity work.immediate_decoder
		generic map(
			WSIZE => WSIZE
		)
		port map(
			instruction      => instruction_in(31 downto 7),
			instruction_type => instruction_type,
			immediate        => immediate
		);

	mux4_ALUA : entity work.mux4
		generic map(
			WSIZE => WSIZE
		)
		port map(
			S  => ALUA_select,
			I0 => r1,
			I1 => PC_IF_ID,
			I2 => BUBBLE,
			I3 => BUBBLE,
			O  => mux_ALUA_out
		);

	mux4_ALUB : entity work.mux4
		generic map(
			WSIZE => WSIZE
		)
		port map(
			S  => ALUB_select,
			I0 => r2,
			I1 => immediate,
			I2 => std_logic_vector(to_unsigned(4, WSIZE)),
			I3 => BUBBLE,
			O  => mux_ALUB_out
		);

	jump_control_inst : entity work.jump_control
		generic map(
			WSIZE => WSIZE
		)
		port map(
			r1             => r1,
			r2             => r2,
			funct3         => funct3,
			opcode         => opcode,
			next_pc_select => next_pc_select
		);

	register_queue_inst : entity work.register_queue
		port map(
			clk              => clk,
			rs1              => rs1,
			rs2              => rs2,
			rd               => rd,
			instruction_type => instruction_type,
			stall            => stall_aux
		);

	process(clk) is
	begin
		if rising_edge(clk) then
			if stall_aux = '1' then
				instruction_out <= BUBBLE;
				wren_memory_out   <= '0';
				wren_register_out <= '0';
			elsif stall_stages /= '1' then
				instruction_out <= instruction_in;
				wren_memory_out   <= wren_memory;
				wren_register_out <= wren_register;
			end if;

			ALU_A_out         <= mux_ALUA_out;
			ALU_B_out         <= mux_ALUB_out;
			wdata_out         <= r2;
			WB_select_out     <= WB_select;
		end if;
	end process;

end architecture stage_ID_arch;
