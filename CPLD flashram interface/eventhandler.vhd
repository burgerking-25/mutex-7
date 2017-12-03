library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity eventhandler is
	port(clock : in std_logic;
		reset : in std_logic;
		i_uart_rx: in std_logic_vector(7 downto 0);
		i_sel: in std_logic_vector(1 downto 0);
		i_rxdone: in std_logic;
		--i_addr_done: in std_logic;
		i_read_done: in std_logic;
		i_write_done: in std_logic;
		o_read : out std_logic;
		o_write: out std_logic;
		o_addressout: out std_logic_vector(18 downto 0));


		--CE: out std_logic;
		--WE: out std_logic;
		--OE: out std_logic;
		--o_Txtrig: out std_logic;
		--io_romdata: inout std_logic_vector(7 downto 0));
end eventhandler;

architecture arch of eventhandler is
	type t_dtSlap_main is (s_IDLE, s_write1,s_write2,s_write3,s_signal,s_putdata,s_tkdata,s_wtputdata,s_wttkdata);
	signal r_GO: t_dtSlap_main := s_IDLE;
	signal r_18_bits_addr: std_logic_vector(18 downto 0):= (others => '0');
	
	--signal r_RD std_logic:= 0;
	--signal r_WE std_logic:= 0;
	signal r_8bits_temp1: std_logic_vector(7 downto 0);

	
	signal wt: integer range 0 to 2 := 0; -- two click cylce delay
	--signal romdata_in std_logic_vector(8 downto 0) := (others => '0');
	--signal romdata_out std_logic_vector(8 downto 0):= (others => '0');
	--signal r_OE std_logic := 
	--signal r_WE std_logic :=
	--signal r_CE std_logic :=
begin

--	update:process(clock)
--	begin
--		if rising_edge(clock) then
--			r_8bits_temp1 <= i_uart_rx;
--		end if;
--	end process;
	
	GO:process(clock, i_rxdone, reset)
		begin
		if(reset = '1') then
			r_GO <= s_IDLE;
			o_addressout <= "0000000000000000000";
			o_read <= '0';
			o_write <= '0';
		
		elsif (rising_edge(clock) and reset = '0') then 
			case r_GO is
					when s_IDLE =>

						if (i_sel = "00" and i_rxdone = '1') then
							r_GO <= s_write1;
						elsif (i_sel ="01" and i_rxdone = '1') then
							r_GO <= s_putdata;
						elsif (i_sel = "10" and i_rxdone = '1') then 
							r_GO <= s_tkdata;
						else
							r_GO <= s_IDLE;
						end if;

					when s_write1 =>
						if(i_rxdone = '1' and wt = 1) then
							--r_18_bits_addr(7 downto 0) <= r_8bits_temp1;
							o_addressout(7 downto 0) <= i_uart_rx;
							wt <= 0;
							r_GO <= s_write2;
						elsif (i_rxdone = '1') then 
							--r_8bits_temp1 <= i_uart_rx;
							r_GO <= s_write1;
							wt <= wt + 1;
						end if;

					when s_write2 =>
						if(i_rxdone = '1' and wt = 1) then
							--r_18_bits_addr(15 downto 8) <= r_8bits_temp1;
							o_addressout(15 downto 8) <= i_uart_rx;
							wt <= 0;
							r_GO <= s_write3;
						elsif (i_rxdone = '1') then
							r_GO <= s_write2;
							--r_8bits_temp1 <= i_uart_rx;
							wt <= wt + 1;
							end if;

					when s_write3 =>
						if(i_rxdone = '1' and wt = 1) then
							--r_18_bits_addr( 18 downto 16) <= r_8bits_temp1(2 downto 0);
							o_addressout(18 downto 16) <= i_uart_rx(2 downto 0);
							wt <= 0;
							r_GO <= s_signal;
						elsif (i_rxdone = '1') then
							--r_8bits_temp1 <= i_uart_rx;
							r_GO <= s_write3;
							wt <= wt + 1;
						end if;

					when s_signal =>
						--o_addressout<= r_18_bits_addr;
						r_GO <= s_IDLE;

					when s_putdata =>
						if (wt = 2) then
							o_write <= '0';
							wt <= 0;
							r_GO <= s_wtputdata;
						else
							o_write <= '1';
							wt <= wt + 1;
							r_GO <= s_putdata;
						end if;

					when s_tkdata =>
						if (wt = 2) then
							o_read <= '0';
							wt <= 0;
							r_GO <= s_wttkdata;
						else
							o_read <= '1';
							wt <= wt + 1;
							r_GO <= s_tkdata;
						end if;
						
					when s_wtputdata =>
						if( i_write_done = '0') then
							r_GO <= s_IDLE;
						else
							r_GO <= s_wtputdata;
						end if;
							
					when s_wttkdata =>
						if( i_read_done = '0') then
							r_GO <= s_IDLE;
						else 
							r_GO <= s_wtputdata;
						end if;
					

					when others =>
						r_GO <= s_IDLE;
				end case;
				
			end if;

	
end process GO;



end architecture ; -- arch