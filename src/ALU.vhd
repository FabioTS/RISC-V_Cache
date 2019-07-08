library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity ALU is
	generic(
		WSIZE : natural
	);
	port(
		ALU_function : in  FUNCTION_TYPE;
		shamt        : in  std_logic_vector(4 downto 0);
		A, B         : in  std_logic_vector((WSIZE - 1) downto 0);
		Z            : out std_logic_vector((WSIZE - 1) downto 0) := (others => '0');
		zero         : out std_logic
	);
end entity ALU;

architecture RTL of ALU is
	signal Zout : std_logic_vector(WSIZE - 1 downto 0) := (others => '0');
begin
	Z    <= Zout;
	zero <= '1' when (signed(Zout) = 0) else '0';

	calc : process(ALU_function, shamt, A, B) is
	begin
		case ALU_function is
			when ALU_ADD => Zout <= std_logic_vector(signed(A) + signed(B));
			when ALU_SUB => Zout <= std_logic_vector(signed(A) - signed(B));
			when ALU_SLL => Zout <= std_logic_vector(shift_left(unsigned(A), to_integer(signed(B))));

			when ALU_SLT =>             -- SLT
				if (signed(A) < signed(B)) then
					Zout <= std_logic_vector(to_unsigned(1, WSIZE));
				else
					Zout <= std_logic_vector(to_unsigned(0, WSIZE));
				end if;

			when ALU_SLTU =>            -- SLT
				if (unsigned(A) < unsigned(B)) then
					Zout <= std_logic_vector(to_unsigned(1, WSIZE));
				else
					Zout <= std_logic_vector(to_unsigned(0, WSIZE));
				end if;

			when ALU_XOR => Zout <= (A xor B);
			when ALU_SRL => Zout <= std_logic_vector(shift_right(unsigned(A), to_integer(signed(B))));
			when ALU_SRA => Zout <= std_logic_vector(shift_right(signed(A), to_integer(signed(B))));
			when ALU_OR => Zout <= (A or B);
			when ALU_AND => Zout <= (A and B);
			when ALU_SLLI => Zout <= std_logic_vector(shift_left(unsigned(A), to_integer(signed(shamt))));
			when ALU_SRLI => Zout <= std_logic_vector(shift_right(unsigned(A), to_integer(signed(shamt))));
			when ALU_SRAI => Zout <= std_logic_vector(shift_right(signed(A), to_integer(signed(shamt))));

			when others => Zout <= std_logic_vector(to_unsigned(0, WSIZE));

		end case;

	end process calc;

end architecture RTL;
