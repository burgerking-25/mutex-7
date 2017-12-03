----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:06:08 11/11/2017 
-- Design Name: 
-- Module Name:    data_read_module - Behavioral 
-- Project Name: 		ECNG 3006 SST39SF040 Flash ROM Interface
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity data_read_module is
	port(clk : in std_logic;
		 i_startread:in std_logic;
		 reset: in std_logic;
		 iv_19_bit:in std_logic_vector(18 downto 0);
		 iv_data_f_ram: in std_logic_vector(7 downto 0);
		 ov_data_t_uart: out std_logic_vector(7 downto 0);
		 ov_19_bit: out std_logic_vector(18 downto 0);
		 o_OE: out std_logic;
		 o_WE: out std_logic;
		 o_CE: out std_logic;
		 o_read_done: out std_logic;
		 o_TX_DV: out std_logic
		  );
end data_read_module;


architecture behavioral of data_read_module is
	type t_reader is (s_IDLE,s_reads1, s_reads2, s_reads3, s_send, s_UARTtrig);
	signal r_reading: t_reader:= s_IDLE;
	signal wt: integer range 0 to 2:= 0;
	signal r_19_bit_address: std_logic_vector(18 downto 0):=(others=>'0');
	signal r_data_in: std_logic_vector(7 downto 0):= (others => '0');
--	signal o_OE :std_logic:= '0';
--	signal o_WE :std_logic:= '1';
--	signal o_CE :std_logic:= '1';
	--signal r_TX_DV: std_logic:= 0;
	--signal r_read_done := 0;
	begin
		GO :process ( clk, i_startread,reset)
			begin
				if reset = '1' then
					r_reading <= s_IDLE;
					o_OE <= '1';
					o_WE <= '1';
					o_CE <= '1';
				elsif(rising_edge(clk)) then
					case r_reading is
						when s_IDLE =>
							o_OE <= '1';
							o_WE <= '1';
							o_CE <= '1';
							o_read_done <= '0';
							o_TX_DV <= '0';	
							if (i_startread = '1') then
								r_reading <= s_reads1;
							else
								r_reading <= s_IDLE;
							end if;

						when s_reads1 =>
							--o_OE <= '1';
							--o_WE <= '1';
							o_CE <= '0';
							r_19_bit_address <= iv_19_bit;
							r_reading <= s_reads2;

						when s_reads2 =>
							o_OE <= '0';
							--o_WE <= '1';
							--o_CE <= '0';
							ov_19_bit <= r_19_bit_address; --present adress on ram pins
							r_reading <= s_reads3;

						when s_reads3 =>
							--o_OE <= '0';
							--o_WE <= '1';
							--o_CE <= '0';
							r_data_in <= iv_data_f_ram;-- store data appearing on ram pins
							r_reading <= s_send;

						when s_send =>
						 	--o_OE <= '0';
						 	--o_WE <= '1';
						 	--o_CE <= '0';
						 	ov_data_t_uart <= r_data_in; -- send data to uart module
						 	r_reading <= s_UARTtrig;

						 when s_UARTtrig =>
						 	--o_OE <= '0';
						 	--o_WE <= '1';
						 	o_CE <= '1';
						 	if (wt /= 2) then 
						 		o_TX_DV <= '1';
						 		o_read_done <= '1';
						 		wt <= wt + 1;
						 		r_reading<= s_UARTtrig;
						 	elsif(wt = 2) then
						 		o_TX_DV <= '0';
						 		o_read_done <= '0';
						 		r_reading <= s_IDLE;
						 	end if;

						 when others =>
						 		r_reading <= s_IDLE;

						 end case;
					--o_OE<= o_OE;
					--o_WE<= o_WE;
					--o_CE<= o_CE; 

				end if;
				

	end process GO;

end architecture;













			



	
