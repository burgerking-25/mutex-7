----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:23:30 11/06/2017 
-- Design Name: 
-- Module Name:    modulo_n_counter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity modulo_n_counter is


port(	clock		:in std_logic;
		data_out :out std_logic_vector(2 downto 0);
		reset 	:in std_logic
);
end modulo_n_counter;

architecture Behavioral of modulo_n_counter is
	signal cnt : std_logic_vector(2 downto 0);
begin
	process(clock,  reset, cnt)
	begin
		if(reset = '1') then
			cnt <= "000";
		elsif(clock'event and clock = '1' ) then
			if(cnt = "101") then
				cnt <= "000";
			else
				cnt <= cnt + 1;
			end if;
		end if;
	end process;
	
	data_out <= cnt;
	end Behavioral;

