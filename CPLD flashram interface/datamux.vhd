




library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use ieee.numeric_std.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity datamux is
	port(iv_8bits_in : in std_logic_vector(7 downto 0);
			clock: in std_logic;
		ov_8bits_out: out std_logic_vector(7 downto 0);
		iv_slct: in std_logic_vector(1 downto 0);
		iov_data_inout: inout std_logic_vector (7 downto 0));


		--CE: out std_logic;
		--WE: out std_logic;
		--OE: out std_logic;
		--o_Txtrig: out std_logic;
		--io_romdata: inout std_logic_vector(7 downto 0));
end datamux;

architecture behavioral of  datamux is
	signal a : std_logic_vector(7 downto 0);--:= (others => '0');
	signal b: std_logic_vector (7 downto 0);--:= (others => '0');

	begin
		update: process(clock)
			begin
				if rising_edge(clock) then
					a <= iv_8bits_in;	 -- input what comes out of reg a- signal a inherits properties of iV_8bits_in
					ov_8bits_out <= b; -- output what you see in reg b (b signals give physical properties of an output by port type
					--ov_bits out    catch_bits <= throw_bits
				end if;
			end process update;
			
			
		flowcontrol: process(iv_slct, iov_data_inout,a)
		begin
			case iv_slct is
--				when "00" =>
--					iov_data_inout <= "ZZZZZZZZ"; -- dont act like an input-- negate inout's in property catch_bits <= "ZZZZZZZZ" catch sleep!
--					b <= iov_data_inout;				-- put what appears in bidir
--				when "01" =>
--					iov_data_inout <= "ZZZZZZZZ";
--					b <= iov_data_inout;  -- out <= out - can only throw
				when "01" =>
					iov_data_inout <= a; -- inhertis properties of signal a become a catcher
					b <= iov_data_inout; -- 
					
				when others =>
					iov_data_inout <= "ZZZZZZZZ";
					b <= iov_data_inout;
					
			end case;
		
		end process flowcontrol;

	end architecture;

