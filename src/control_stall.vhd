library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constants.all;

entity control_stall is
	port(
				stall_id, stall_mem        : in  std_logic;
				stall_if, stall_stages     : out std_logic
	);
end entity control_stall;

architecture RTL of control_stall is
	
begin
	process(stall_id, stall_mem) is
	begin
		if (stall_id = '1' and stall_mem = '0') then
			stall_if     <= '1';
			stall_stages <= '0';
		elsif (stall_mem = '1') then
			stall_if     <= '1';
			stall_stages <= '1';
		else
			stall_if     <= '0';
			stall_stages <= '0';
		end if;
	end process;

end architecture RTL;
