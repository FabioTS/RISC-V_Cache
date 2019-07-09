library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package constants is
	-- Configuration
	constant WORD_SIZE                      : natural := 32;
	constant DEFAULT_INSTRUCTIONS_INIT_FILE : string  := "MEM_INSTR.mif";
	constant DEFAULT_DATA_INIT_FILE         : string  := "MEM_DADOS.mif";
	constant DATA_MEMORY_ADDRESS_OFFSET     : integer := - 16#00002000#; -- This value will be subtract from all memory addresses
	constant RAM_ADDRESS_SIZE               : natural := 13;
	
	-- Cache param
	constant BLK_SIZE	: natural := 8;
	constant N_BLK	: natural := 16;
	-- Cache size is equal to WORD_SIZE*LINE_SIZE*N_LINES = 32*8*16 = 4096 bits = 1024 bytes = 1KiB ~= 1 KB
	
	constant LOG2_BLK_SIZE	: natural := natural(ceil(log2(real(BLK_SIZE)))); -- 3
	constant LOG2_N_BLK	: natural := natural(ceil(log2(real(N_BLK)))); -- 4
	
	-- Breg typedef
	TYPE ARRAY_32X32 is array (0 to WORD_SIZE - 1) of std_logic_vector(WORD_SIZE - 1 downto 0);

	-- Opcodes
	constant OPCODE_LOAD       : std_logic_vector(6 downto 0) := "0000011";
	constant OPCODE_LOAD_FP    : std_logic_vector(6 downto 0) := "0000111"; -- TODO: Not implemented
	constant OPCODE_CUSTOM_0   : std_logic_vector(6 downto 0) := "0001011"; -- TODO: Not implemented
	constant OPCODE_MISC_MEM   : std_logic_vector(6 downto 0) := "0001111"; -- TODO: Not implemented
	constant OPCODE_OP_IMM     : std_logic_vector(6 downto 0) := "0010011";
	constant OPCODE_AUIPC      : std_logic_vector(6 downto 0) := "0010111";
	constant OPCODE_OP_IMM_32  : std_logic_vector(6 downto 0) := "0011011"; -- TODO: Not implemented
	--	constant OPCODE_           : std_logic_vector(6 downto 0) := "0011111";
	constant OPCODE_STORE      : std_logic_vector(6 downto 0) := "0100011";
	constant OPCODE_STORE_FP   : std_logic_vector(6 downto 0) := "0100111"; -- TODO: Not implemented
	constant OPCODE_CUSTOM_1   : std_logic_vector(6 downto 0) := "0101011"; -- TODO: Not implemented
	constant OPCODE_AMO        : std_logic_vector(6 downto 0) := "0101111"; -- TODO: Not implemented
	constant OPCODE_OP         : std_logic_vector(6 downto 0) := "0110011";
	constant OPCODE_LUI        : std_logic_vector(6 downto 0) := "0110111";
	constant OPCODE_OP_32      : std_logic_vector(6 downto 0) := "0111011"; -- TODO: Not implemented
	--	constant OPCODE_           : std_logic_vector(6 downto 0) := "0111111";
	constant OPCODE_MADD       : std_logic_vector(6 downto 0) := "1000011"; -- TODO: Not implemented
	constant OPCODE_MSUB       : std_logic_vector(6 downto 0) := "1000111"; -- TODO: Not implemented
	constant OPCODE_NMSUB      : std_logic_vector(6 downto 0) := "1001011"; -- TODO: Not implemented
	constant OPCODE_NMADD      : std_logic_vector(6 downto 0) := "1001111"; -- TODO: Not implemented
	constant OPCODE_OP_FP      : std_logic_vector(6 downto 0) := "1010011"; -- TODO: Not implemented
	constant OPCODE_RESERVED_1 : std_logic_vector(6 downto 0) := "1010111"; -- TODO: Not implemented
	constant OPCODE_CUSTOM_2   : std_logic_vector(6 downto 0) := "1011011"; -- TODO: Not implemented
	--	constant OPCODE_           : std_logic_vector(6 downto 0) := "1011111";
	constant OPCODE_BRANCH     : std_logic_vector(6 downto 0) := "1100011";
	constant OPCODE_JALR       : std_logic_vector(6 downto 0) := "1100111";
	constant OPCODE_RESERVED_2 : std_logic_vector(6 downto 0) := "1101011"; -- TODO: Not implemented
	constant OPCODE_JAL        : std_logic_vector(6 downto 0) := "1101111";
	constant OPCODE_SYSTEM     : std_logic_vector(6 downto 0) := "1110011"; -- TODO: Not implemented
	constant OPCODE_RESERVED_3 : std_logic_vector(6 downto 0) := "1110111"; -- TODO: Not implemented
	constant OPCODE_CUSTOM_3   : std_logic_vector(6 downto 0) := "1111011"; -- TODO: Not implemented
	--	constant OPCODE_           : std_logic_vector(6 downto 0) := "1111111";

	-- IMMEDIATE FUNCT3 ALU FUNCTIONS
	constant FUNCT3_ADDI  : std_logic_vector(2 downto 0) := "000";
	constant FUNCT3_SLTI  : std_logic_vector(2 downto 0) := "010";
	constant FUNCT3_SLTIU : std_logic_vector(2 downto 0) := "011";
	constant FUNCT3_XORI  : std_logic_vector(2 downto 0) := "100";
	constant FUNCT3_ORI   : std_logic_vector(2 downto 0) := "110";
	constant FUNCT3_ANDI  : std_logic_vector(2 downto 0) := "111";
	constant FUNCT3_SLLI  : std_logic_vector(2 downto 0) := "001";
	constant FUNCT3_SRLI  : std_logic_vector(2 downto 0) := "101";
	constant FUNCT3_SRAI  : std_logic_vector(2 downto 0) := "101";

	-- NORMAL FUNCT3 ALU FUNCTIONS
	constant FUNCT3_ADD  : std_logic_vector(2 downto 0) := "000";
	constant FUNCT3_SUB  : std_logic_vector(2 downto 0) := "000";
	constant FUNCT3_SLL  : std_logic_vector(2 downto 0) := "001";
	constant FUNCT3_SLT  : std_logic_vector(2 downto 0) := "010";
	constant FUNCT3_SLTU : std_logic_vector(2 downto 0) := "011";
	constant FUNCT3_XOR  : std_logic_vector(2 downto 0) := "100";
	constant FUNCT3_SRL  : std_logic_vector(2 downto 0) := "101";
	constant FUNCT3_SRA  : std_logic_vector(2 downto 0) := "101";
	constant FUNCT3_OR   : std_logic_vector(2 downto 0) := "110";
	constant FUNCT3_AND  : std_logic_vector(2 downto 0) := "111";

	-- BRANCH FUNCT3
	constant FUNCT3_BEQ  : std_logic_vector(2 downto 0) := "000";
	constant FUNCT3_BNE  : std_logic_vector(2 downto 0) := "001";
	constant FUNCT3_BLT  : std_logic_vector(2 downto 0) := "100";
	constant FUNCT3_BGE  : std_logic_vector(2 downto 0) := "101";
	constant FUNCT3_BLTU : std_logic_vector(2 downto 0) := "110";
	constant FUNCT3_BGEU : std_logic_vector(2 downto 0) := "111";

	-- IMMEDIATE FUNCT7 ALU FUNCTIONS
	constant FUNCT7_SLLI : std_logic_vector(6 downto 0) := "0000000";
	constant FUNCT7_SRLI : std_logic_vector(6 downto 0) := "0000000";
	constant FUNCT7_SRAI : std_logic_vector(6 downto 0) := "0100000";
	-- NORMAL FUNCT7 ALU FUNCTIONS
	constant FUNCT7_ADD  : std_logic_vector(6 downto 0) := "0000000";
	constant FUNCT7_SUB  : std_logic_vector(6 downto 0) := "0100000";
	constant FUNCT7_SLL  : std_logic_vector(6 downto 0) := "0000000";
	constant FUNCT7_SLT  : std_logic_vector(6 downto 0) := "0000000";
	constant FUNCT7_SLTU : std_logic_vector(6 downto 0) := "0000000";
	constant FUNCT7_XOR  : std_logic_vector(6 downto 0) := "0000000";
	constant FUNCT7_SRL  : std_logic_vector(6 downto 0) := "0000000";
	constant FUNCT7_SRA  : std_logic_vector(6 downto 0) := "0100000";
	constant FUNCT7_OR   : std_logic_vector(6 downto 0) := "0000000";
	constant FUNCT7_AND  : std_logic_vector(6 downto 0) := "0000000";

	-- STORE INSTRUCTION FUNCT3
	constant FUNCT3_SB : std_logic_vector(2 downto 0) := "000";
	constant FUNCT3_SH : std_logic_vector(2 downto 0) := "001";
	constant FUNCT3_SW : std_logic_vector(2 downto 0) := "010";

	type FUNCTION_TYPE is (
		ALU_ADD,
		ALU_SUB,
		ALU_SLL,
		ALU_SLT,
		ALU_SLTU,
		ALU_XOR,
		ALU_SRL,
		ALU_SRA,
		ALU_OR,
		ALU_AND,
		ALU_SLLI,
		ALU_SRLI,
		ALU_SRAI
	);

	-- Instructions type
	type instruction_types is (
		R_type,
		I_type,
		S_type,
		B_type,
		U_type,
		J_type
	);

	-- ULA selector
	constant ALUA_SELECT_RS1    : std_logic_vector(1 downto 0) := "00";
	constant ALUA_SELECT_PC     : std_logic_vector(1 downto 0) := "01";
	constant ALUA_SELECT_BUBBLE : std_logic_vector(1 downto 0) := "11";

	constant ALUB_SELECT_RS2    : std_logic_vector(1 downto 0) := "00";
	constant ALUB_SELECT_IMM    : std_logic_vector(1 downto 0) := "01";
	constant ALUB_SELECT_4      : std_logic_vector(1 downto 0) := "10";
	constant ALUB_SELECT_BUBBLE : std_logic_vector(1 downto 0) := "11";

	-- WriteBack selector
	constant WB_SELECT_ALU : std_logic := '0';
	constant WB_SELECT_MEM : std_logic := '1';

	-- Next PC selector
	constant PC_SELECT_PLUS4 : std_logic_vector(1 downto 0) := "00";
	constant PC_SELECT_JAL   : std_logic_vector(1 downto 0) := "01";
	constant PC_SELECT_JALR  : std_logic_vector(1 downto 0) := "10";
	constant PC_SELECT_BR    : std_logic_vector(1 downto 0) := "11";

	constant BUBBLE : std_logic_vector((WORD_SIZE - 1) downto 0) := (others => '0');

end package constants;

package body constants is
end package body constants;
