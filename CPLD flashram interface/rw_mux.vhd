library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use ieee.numeric_std.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity rw_mux is
	port(slct: in std_logic_vector(1 downto 0);
		wr_OE: in std_logic;
		wr_WE: in std_logic;
		wr_CE: in std_logic;
		re_OE: in std_logic;
		re_WE: in std_logic;
		re_CE: in std_logic;
		out_OE: out std_logic;
		out_WE: out std_logic;
		out_CE: out std_logic);
	end  rw_mux;

	architecture behavioral of rw_mux is
	
	begin
		process(slct, wr_OE, wr_WE, wr_CE, re_OE, re_WE, re_CE)
		begin
			case slct is

				when "10" =>
				out_OE <= re_OE;
				out_WE <= re_WE;
				out_CE <= re_CE;

				when others =>
				out_OE <= wr_OE;
				out_WE <= wr_WE;
				out_CE <= wr_CE;

			end case;
		end process;
	end architecture;


