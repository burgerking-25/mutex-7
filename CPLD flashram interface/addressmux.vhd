----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:27:32 11/15/2017 
-- Design Name: 
-- Module Name:    addressmux - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity addressmux is
    Port ( slct : in  STD_LOGIC_VECTOR (1 downto 0);
           iv_rdaddress : in  STD_LOGIC_VECTOR (18 downto 0);
           iv_wraddress : in  STD_LOGIC_VECTOR (18 downto 0);
           ov_address_out : out  STD_LOGIC_VECTOR (18 downto 0));
end addressmux;

architecture Behavioral of addressmux is

begin
	process(slct, iv_rdaddress,iv_wraddress)
	begin
		case slct is 
			when "10" =>
				ov_address_out <= iv_rdaddress;
			when others =>
				ov_address_out <= iv_wraddress;
		end case;
	end process; 
				


end Behavioral;

