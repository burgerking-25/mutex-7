-- Company: Mutex-7
-- Engineer: Luther Jn. Baptiste (assistant)


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity data_write_module is
	port(clk : in std_logic;
		 i_startwrite:in std_logic;
		 reset: in std_logic;
		 iv_19_bit:in std_logic_vector(18 downto 0);
		 iv_data_f_uart: in std_logic_vector(7 downto 0);
		 ov_19_bit: out std_logic_vector(18 downto 0);
		 ov_dataout: out std_logic_vector(7 downto 0);
		 o_OE: out std_logic;
		 o_WE: out std_logic;
		 o_CE: out std_logic;
		 o_write_done: out std_logic
		  );
end data_write_module;

architecture behavioural of data_write_module is
	type t_scribe is (s_IDLE,s_load1,s_load2,s_load3,s_loadD,s_write1,s_write2,s_write3,
					s_writeD, s_finish1, s_finish2, s_finish3, s_finishD, s_signal);
	signal r_writer: t_scribe := s_IDLE; 
	signal r_address_in: std_logic_vector(18 downto 0):= (others => '0');
	--signal r_data_in: std_logic_vector(7 downto 0):= (others => '0');
	signal wt: integer range 0 to 2 :=0;

	begin
		essay: process(clk, reset, i_startwrite, wt)
			begin
				if (reset = '1') then
					o_OE <='0';
					o_CE <='1';
					o_WE <='1';
					r_writer <= s_IDLE;
					o_write_done <= '0';

				elsif (rising_edge(clk)) then
					case r_writer is
						when s_IDLE =>
							ov_dataout <="00000000";
							ov_19_bit <="0000000000000000000";
							o_OE <= '0';
							o_WE <= '1';
							o_CE <= '1';
							if (i_startwrite = '1') then
								r_writer <= s_load1;
							else
								r_writer <= s_IDLE;
							end if;

						when s_load1 =>
							o_WE <='1'; 
							o_CE <='0';
							--o_OE <='1';
							r_address_in <= iv_19_bit;
							--r_data_in <= iv_data_f_uart;
							ov_dataout <="10101010";--AA
							ov_19_bit <="0000101010101010101";--5555
							r_writer <= s_write1;

						when s_write1 =>
							o_WE <='0'; 
							--o_CE <='0';
							--o_OE <='1';
							--ov_dataout <="10101010";--AA
							--ov_19_bit <="0000101010101010101";--5555
							r_writer <= s_finish1;

						when s_finish1 =>
							o_WE <='1'; 
							--o_CE <='0';
							--o_OE <='1';
							--ov_dataout <="10101010";--AA
							--ov_19_bit <="0000101010101010101";--5555
							r_writer <= s_load2;

						when s_load2 =>
							--o_WE <='1'; 
							--o_CE <='0';
							--o_OE <='1';
							ov_dataout <="01010101";--55
							ov_19_bit <="0000010101010101010";--2AAA
							r_writer <= s_write2;

						when s_write2 =>
							o_WE <='0'; 
							--o_CE <='0';
							--o_OE <='1';
							--ov_dataout <="01010101";--55
							--ov_19_bit <="0000010101010101010";--2AAA
							r_writer <= s_finish2;

						when s_finish2 =>
							o_WE <='1'; 
							--o_CE <='0';
							--o_OE <='1';
							--ov_dataout <="01010101";--55
							--ov_19_bit <="0000010101010101010";--2AAA
							r_writer <= s_load3;

						when s_load3 =>
							--o_WE <='1'; 
							--o_CE <='0';
							--o_OE <='1';
							ov_dataout <= "10100000"; -- A0
							ov_19_bit <= "0000101010101010101";--5555
							r_writer <= s_write3;

						when s_write3 =>
							o_WE <='0'; 
							--o_CE <='0';
							--o_OE <='1';
							--ov_dataout <="10100000"; -- A0
							--ov_19_bit <= "0000101010101010101";--5555
							r_writer <= s_finish3;

						when s_finish3 =>
							o_WE <='1'; 
							--o_CE <='0';
							--o_OE <='1';
							--ov_dataout <="10100000"; -- A0
							--ov_19_bit <= "0000101010101010101";--5555
							r_writer <= s_loadD;


							when s_loadD =>
							--o_WE <='1'; 
							--o_CE <='0';
							--o_OE <='1';
							ov_dataout <= iv_data_f_uart;
							ov_19_bit <= r_address_in;
							r_writer <= s_writeD;

						when s_writeD =>
							o_WE <='0'; 
							--o_CE <='0';
							--o_OE <='1';
							--ov_dataout <= r_data_in;
							--ov_19_bit <= r_address_in;
							r_writer <= s_finishD;

						when s_finishD =>
							o_WE <='1'; 
							--o_CE <='0';
							--o_OE <='1';
							--ov_dataout <= r_data_in;
							--ov_19_bit <= r_address_in;
							r_writer <= s_signal;

						when s_signal =>
							if (wt = 2) then
								wt <= 0;
								o_write_done <= '0';
								r_writer <= s_IDLE;

							elsif (wt /= 2) then 
								wt <= wt + 1;
								o_write_done <= '1';
								r_writer <= s_signal;
							end if;


						when others =>
							r_writer <= s_IDLE;

						end case;
					end if;
				end process essay;
			end architecture;







							
