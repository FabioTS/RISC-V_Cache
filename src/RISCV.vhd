library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity RISCV is
	generic(
		WSIZE                  : natural := WORD_SIZE;
		instructions_init_file : string  := DEFAULT_INSTRUCTIONS_INIT_FILE;
		data_init_file         : string  := DEFAULT_DATA_INIT_FILE
	);

	port(
		clk             : in  std_logic;
		instruction     : out std_logic_vector(WSIZE - 1 downto 0)
--		registers_array : out ARRAY_32X32
		--*--*--*--*--*--*--*--*--*--*--*--*--*--*--* Signals necessary to FPGA, comment when simulating in modelsim and uncomment above --*--*--*--*--*--*--*--*--*--*--*--*--*--*--*
		--		clk50, clk_key                                 : in  std_logic;
		--		MUX_FPGA_select                                : in  std_logic_vector(1 downto 0);
		--		reg_number                                     : in  std_logic_vector(4 downto 0);
		--		hex7, hex6, hex5, hex4, hex3, hex2, hex1, hex0 : out std_logic_vector(7 downto 0)
		--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*
	);
end RISCV;

architecture RISCV_arch of RISCV is
	--*--*--*--*--*--*--*--*--*--*--*--*--*--*--* Signals necessary to FPGA, comment when simulating in modelsim --*--*--*--*--*--*--*--*--*--*--*--*--*--*--*
	--	signal clk, clk_out                                                           : std_logic;
	--	signal registers_array                                                        : ARRAY_32X32;
	--	signal MUX_FPGA_out, reg_display                                              : std_logic_vector(31 downto 0);
	--	signal hex0aux, hex1aux, hex2aux, hex3aux, hex4aux, hex5aux, hex6aux, hex7aux : std_logic_vector(7 downto 0);
	--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*

	signal instruction_IF_ID, instruction_ID_EX, instruction_EX_MEM, instruction_MEM_WB : std_logic_vector((WSIZE - 1) downto 0);
	signal ALU_A, ALU_B, ALU_Z, wdata_ID_EX, wdata_EX_MEM                               : std_logic_vector((WSIZE - 1) downto 0) := (others => '0');
	signal WB_data, data_MEM_WB, immediate, rs1                                         : std_logic_vector((WSIZE - 1) downto 0);
	signal PC_IF_ID                                                                     : std_logic_vector((WSIZE - 1) downto 0);

	signal WB_address     : std_logic_vector(4 downto 0);
	signal next_pc_select : std_logic_vector(1 downto 0);

	signal wren_register_ID_EX, wren_register_EX_MEM, wren_register_MEM_WB, wren_register_WB : std_logic;
	signal wren_memory_ID_EX, wren_memory_EX_MEM                                             : std_logic;
	signal WB_select_ID_EX, WB_select_EX_MEM, stall                                          : std_logic;

	signal address_ram            : std_logic_vector(RAM_ADDRESS_SIZE-1 downto 0);
	signal data_blk_out           : std_logic_vector((WORD_SIZE * BLK_SIZE) - 1 downto 0);
	signal wren_ram               : std_logic;
	signal data_blk_in            : std_logic_vector((WORD_SIZE * BLK_SIZE) - 1 downto 0);
	signal read_ram               : std_logic;
	signal hold_ram               : std_logic;
	signal ready_ram              : std_logic;
	signal stall_mem, stall_id    : std_logic;
	signal stall_if, stall_stages : std_logic := '0';
	
	signal read_hit : std_logic;
	signal read_miss : std_logic;
	signal write_hit : std_logic;
	signal write_miss : std_logic;
	signal write_back : std_logic;
	signal read_hit_count, read_miss_count, write_hit_count, write_miss_count, write_back_count : natural := 0;

begin

	instruction <= instruction_IF_ID;
	--*--*--*--*--*--*--*--*--*--*--*--*--*--*--* Signals necessary to FPGA, comment when simulating in modelsim and uncomment above --*--*--*--*--*--*--*--*--*--*--*--*--*--*--*
	--	reg_display <= registers_array(to_integer(unsigned(reg_number)));
	--
	--	hex7 <= hex7aux;
	--	hex6 <= hex6aux;
	--	hex5 <= hex5aux;
	--	hex4 <= hex4aux;
	--	hex3 <= hex3aux;
	--	hex2 <= hex2aux;
	--	hex1 <= hex1aux;
	--	hex0 <= hex0aux;
	--
	--	mux4_FPGA : entity work.mux4
	--		generic map(WSIZE => WSIZE)
	--		port map(MUX_FPGA_select, PC_IF_ID, instruction_IF_ID, BUBBLE, reg_display, MUX_FPGA_out);
	--	-- cada portmap ira gerar os sinais que serao enviados para o FPGA
	--	HEX_0 : entity work.display7seg_decoder
	--		port map(MUX_FPGA_out(31 downto 28), hex7aux);
	--	HEX_1 : entity work.display7seg_decoder
	--		port map(MUX_FPGA_out(27 downto 24), hex6aux);
	--	HEX_2 : entity work.display7seg_decoder
	--		port map(MUX_FPGA_out(23 downto 20), hex5aux);
	--	HEX_3 : entity work.display7seg_decoder
	--		port map(MUX_FPGA_out(19 downto 16), hex4aux);
	--	HEX_4 : entity work.display7seg_decoder
	--		port map(MUX_FPGA_out(15 downto 12), hex3aux);
	--	HEX_5 : entity work.display7seg_decoder
	--		port map(MUX_FPGA_out(11 downto 8), hex2aux);
	--	HEX_6 : entity work.display7seg_decoder
	--		port map(MUX_FPGA_out(7 downto 4), hex1aux);
	--	HEX_7 : entity work.display7seg_decoder
	--		port map(MUX_FPGA_out(3 downto 0), hex0aux);
	--
	--	debounce_inst : entity work.debounce
	--		generic map(
	--			counter_size => 19
	--		)
	--		port map(
	--			clk    => clk50,
	--			button => clk_key,
	--			result => clk_out
	--		);
	--	clk <= not clk_out;
	--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*

	stage_IF_inst : entity work.stage_IF
		generic map(
			WSIZE                  => WSIZE,
			instructions_init_file => instructions_init_file
		)
		port map(
			clk             => clk,
			immediate       => immediate,
			rs1             => rs1,
			next_pc_select  => next_pc_select,
			stall           => stall_if,
			instruction_out => instruction_IF_ID,
			PC_IF_ID_out    => PC_IF_ID
		);

	stage_ID_inst : entity work.stage_ID
		generic map(
			WSIZE => WSIZE
		)
		port map(
			stall_stages      => stall_stages,
			clk               => clk,
			instruction_in    => instruction_IF_ID,
			instruction_out   => instruction_ID_EX,
			WB_data           => WB_data,
			WB_address        => WB_address,
			wren_register_in  => wren_register_WB,
			wren_memory_out   => wren_memory_ID_EX,
			wren_register_out => wren_register_ID_EX,
			WB_select_out     => WB_select_ID_EX,
			stall_id          => stall_id,
			wdata_out         => wdata_ID_EX,
			ALU_A_out         => ALU_A,
			ALU_B_out         => ALU_B,
			immediate_out     => immediate,
			rs1_out           => rs1,
			PC_IF_ID          => PC_IF_ID,
			next_pc_select    => next_pc_select,
			registers_array   => open --registers_array
		);

	stage_EX_inst : entity work.stage_EX
		generic map(
			WSIZE => WSIZE
		)
		port map(
			stall_stages      => stall_stages,
			clk               => clk,
			instruction_in    => instruction_ID_EX,
			instruction_out   => instruction_EX_MEM,
			wdata_in          => wdata_ID_EX,
			wdata_out         => wdata_EX_MEM,
			ALU_A             => ALU_A,
			ALU_B             => ALU_B,
			ALU_Z             => ALU_Z,
			wren_memory_in    => wren_memory_ID_EX,
			wren_register_in  => wren_register_ID_EX,
			WB_select_in      => WB_select_ID_EX,
			wren_memory_out   => wren_memory_EX_MEM,
			wren_register_out => wren_register_EX_MEM,
			WB_select_out     => WB_select_EX_MEM
		);

	stage_MEM_inst : entity work.stage_MEM
		generic map(
			WSIZE          => WSIZE,
			data_init_file => data_init_file
		)
		port map(
			stall_stages      => stall_stages,
			clk               => clk,
			instruction_in    => instruction_EX_MEM,
			instruction_out   => instruction_MEM_WB,
			wdata_in          => wdata_EX_MEM,
			address           => ALU_Z,
			data_out          => data_MEM_WB,
			wren_memory_in    => wren_memory_EX_MEM,
			wren_register_in  => wren_register_EX_MEM,
			WB_select_in      => WB_select_EX_MEM,
			wren_register_out => wren_register_MEM_WB,
			stall_mem         => stall_mem,
			read_hit          => read_hit,
			read_miss         => read_miss,
			write_hit         => write_hit,
			write_miss        => write_miss,
			write_back        => write_back,
			address_ram       => address_ram,
			data_blk_out      => data_blk_out,
			wren_ram          => wren_ram,
			data_blk_in       => data_blk_in,
			read_ram          => read_ram,
			hold_ram          => hold_ram,
			ready_ram         => ready_ram
		);

	stage_WB_inst : entity work.stage_WB
		generic map(
			WSIZE => WSIZE
		)
		port map(
			clk               => clk,
			instruction_in    => instruction_MEM_WB,
			data_in           => data_MEM_WB,
			wren_register_in  => wren_register_MEM_WB,
			wren_register_out => wren_register_WB,
			WB_address        => WB_address,
			WB_data_out       => WB_data
		);

	control_stall_inst : entity work.control_stall
		port map(
			clk          => clk,
			stall_id     => stall_id,
			stall_mem    => stall_mem,
			stall_if     => stall_if,
			stall_stages => stall_stages
		);

	ram_inst : entity work.ram2
		generic map(
			--			init_file => "RAM_DATA.hex"
			init_file => data_init_file
		)
		port map(
			address => address_ram,
			clock   => clk,
			data    => data_blk_out,
			wren    => wren_ram,
			q       => data_blk_in,
			read    => read_ram,
			hold    => hold_ram,
			ready   => ready_ram
		);
		
		cache_cnt : process(clk) is
		begin
			if rising_edge(clk) then
				if(read_hit = '1') then
					read_hit_count <= read_hit_count + 1;
				elsif (read_miss = '1') then 
					read_miss_count <= read_miss_count + 1;
				elsif (read_miss = '1') then 
					write_hit_count <= write_hit_count + 1;
				elsif (read_miss = '1') then 
					write_miss_count <= write_miss_count + 1;
				elsif (read_miss = '1') then 
					write_back_count <= write_back_count + 1;
				end if;
			end if;
		end process cache_cnt;
		

end RISCV_arch;
