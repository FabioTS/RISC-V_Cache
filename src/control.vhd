library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity control is
	generic(WSIZE : natural);

	port(
		instruction                : in  std_logic_vector(WSIZE - 1 downto 0);
		instruction_type           : out instruction_types;
		ALUA_select, ALUB_select   : out std_logic_vector(1 downto 0);
		WB_select                  : out std_logic;
		wren_memory, wren_register : out std_logic
	);
end entity control;

architecture control_arch of control is
	alias opcode : std_logic_vector(6 downto 0) is instruction(6 downto 0);

begin

	process(instruction) is
	begin
		case opcode is
			when OPCODE_LOAD =>
				instruction_type <= I_type;
				ALUA_select      <= ALUA_SELECT_RS1;
				ALUB_select      <= ALUB_SELECT_IMM;
				wren_memory      <= '0';
				wren_register    <= '1';
				WB_select        <= WB_SELECT_MEM;

			when OPCODE_OP_IMM =>
				instruction_type <= I_type;
				ALUA_select      <= ALUA_SELECT_RS1;
				ALUB_select      <= ALUB_SELECT_IMM;
				wren_memory      <= '0';
				wren_register    <= '1';
				WB_select        <= WB_SELECT_ALU;

			when OPCODE_STORE =>
				instruction_type <= S_type;
				ALUA_select      <= ALUA_SELECT_RS1;
				ALUB_select      <= ALUB_SELECT_IMM;
				wren_memory      <= '1';
				wren_register    <= '0';
				WB_select        <= WB_SELECT_ALU;

			when OPCODE_OP =>
				instruction_type <= R_type;
				ALUA_select      <= ALUA_SELECT_RS1;
				ALUB_select      <= ALUB_SELECT_RS2;
				wren_memory      <= '0';
				wren_register    <= '1';
				WB_select        <= WB_SELECT_ALU;

			when OPCODE_LUI =>
				instruction_type <= U_type;
				ALUA_select      <= ALUA_SELECT_RS1;
				ALUB_select      <= ALUB_SELECT_IMM;
				wren_memory      <= '0';
				wren_register    <= '1';
				WB_select        <= WB_SELECT_ALU;

			when OPCODE_BRANCH =>
				instruction_type <= B_type;
				ALUA_select      <= ALUA_SELECT_RS1;
				ALUB_select      <= ALUB_SELECT_IMM;
				wren_memory      <= '0';
				wren_register    <= '0';
				WB_select        <= WB_SELECT_ALU;

			when OPCODE_JALR =>
				instruction_type <= I_type;
				ALUA_select      <= ALUA_SELECT_PC;
				ALUB_select      <= ALUB_SELECT_4;
				wren_memory      <= '0';
				wren_register    <= '1';
				WB_select        <= WB_SELECT_ALU;

			when OPCODE_JAL =>
				instruction_type <= J_type;
				ALUA_select      <= ALUA_SELECT_PC;
				ALUB_select      <= ALUB_SELECT_4;
				wren_memory      <= '0';
				wren_register    <= '1';
				WB_select        <= WB_SELECT_ALU;

			when OPCODE_AUIPC =>
				instruction_type <= U_type;
				ALUA_select      <= ALUA_SELECT_PC;
				ALUB_select      <= ALUB_SELECT_IMM;
				wren_memory      <= '0';
				wren_register    <= '1';
				WB_select        <= WB_SELECT_ALU;

			when others =>
				instruction_type <= J_type;
				ALUA_select      <= ALUA_SELECT_RS1;
				ALUB_select      <= ALUB_SELECT_IMM;
				wren_memory      <= '0';
				wren_register    <= '0';
				WB_select        <= WB_SELECT_ALU;
		end case;
	end process;

end architecture control_arch;
