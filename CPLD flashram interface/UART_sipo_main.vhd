----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:25:16 11/13/2017 
-- Design Name: 
-- Module Name:    UART_sipo_main - Behavioral 
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

entity UART_sipo_main is
	port(o_Address: out std_logic_vector(18 downto 0);
			io_data: inout std_logic_vector(7 downto 0);
			OE: out std_logic;
			WE: out std_logic;
			CE: out std_logic;
			UART_RXser: in std_logic;
			clk : in std_logic;
		 	reset: in std_logic;
		 	slct: in std_logic_vector(1 downto 0);
			UART_TXser: out std_logic;
			TXactive: out std_logic;
			RXactive: out std_logic);

end UART_sipo_main;

architecture Behavioral of UART_sipo_main is

component data_read_module 
		port(clk: in std_logic;
			i_startread : IN  std_logic;
			reset : IN  std_logic;
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
end component;

component data_write_module -- writer
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
end component;


component datamux  -- data pins
	port(iv_8bits_in : in std_logic_vector(7 downto 0);
			clock: in std_logic;
		ov_8bits_out: out std_logic_vector(7 downto 0);
		iv_slct: in std_logic_vector(1 downto 0);
		iov_data_inout: inout std_logic_vector (7 downto 0));

end component;

component eventhandler 
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

end component;

component frequency_divider 
  Port(clk    : in std_logic;
       reset  : in std_logic;
		 clock1 : inout std_logic);
end component;



component rw_mux 
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
	end  component;

component UART_TX 
  generic (
    g_CLKS_PER_BIT : integer := 417     -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_TX_DV     : in  std_logic;
    i_TX_Byte   : in  std_logic_vector(7 downto 0);
    o_TX_Active : out std_logic;
    o_TX_Serial : out std_logic;
    o_TX_Done   : out std_logic
    );
end component;

component UART_RX 
  generic (
    g_CLKS_PER_BIT : integer := 417     -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_RX_Serial : in  std_logic;
    o_RX_DV     : out std_logic;
    o_RX_Byte   : out std_logic_vector(7 downto 0);
	 o_RX_done   : out std_logic -- added this
    );
end component;

component addressmux 
    Port ( slct : in  STD_LOGIC_VECTOR (1 downto 0);
           iv_rdaddress : in  STD_LOGIC_VECTOR (18 downto 0);
           iv_wraddress : in  STD_LOGIC_VECTOR (18 downto 0);
           ov_address_out : out  STD_LOGIC_VECTOR (18 downto 0));
end component;

--------------signals------------------------
		signal w_wr_OE:  std_logic;
		signal w_wr_WE:  std_logic;
		signal w_wr_CE:  std_logic;
		signal w_re_OE:  std_logic;
		signal w_re_WE:  std_logic;
		signal w_re_CE:  std_logic;
		--signal slct: std_logic;

		constant c_CLKS_PER_BIT : integer := 417;
		--uart rx
		signal UART_RX_bits: std_logic_vector(7 downto 0);
		signal w_RX_done: std_logic;
		signal w_RX_DV: std_logic;


		--uart tx
		signal UART_TX_bits: std_logic_vector(7 downto 0);
		signal w_TX_done: std_logic;
		signal w_TX_DV: std_logic;
		
		--address
		signal b_eventhandler_address: std_logic_vector(18 downto 0);
		signal b_readaddress: std_logic_vector(18 downto 0);
		signal b_writeaddress: std_logic_vector(18 downto 0);

		--data
		signal b_data_TX: std_logic_vector(7 downto 0);
		signal b_data_RX: std_logic_vector(7 downto 0);
		signal data_f_datamux: std_logic_vector(7 downto 0);
		signal data_t_datamux: std_logic_vector(7 downto 0);

		--clock
		signal clk_4MHz: std_logic;


		-- start reads start writes
		signal w_write_done: std_logic;
		signal w_startwrite: std_logic;
		signal w_read_done: std_logic;
		signal w_startread: std_logic;


begin
cop1: data_read_module 
		port map(clk => clk_4MHz,
			reset => reset,
			i_startread => w_startread,
			iv_19_bit=>b_eventhandler_address,
		 iv_data_f_ram=>data_f_datamux,
		 ov_data_t_uart=>b_data_RX,
		 ov_19_bit=>b_readaddress, 
		 o_OE=>w_re_OE,
		 o_WE=>w_re_WE,
		 o_CE=>w_re_CE,
		 o_read_done=> w_read_done,
		 o_TX_DV=> w_TX_DV
		  );


cop2: data_write_module -- writer
	port map(clk => clk_4MHz,
		 i_startwrite=> w_startwrite,
		 reset => reset,
		 iv_19_bit =>b_eventhandler_address,
		 iv_data_f_uart =>b_data_RX,
		 ov_19_bit =>b_writeaddress,
		 ov_dataout =>data_t_datamux,
		 o_OE =>w_wr_OE,
		 o_WE =>w_wr_WE,
		 o_CE =>w_wr_CE,
		 o_write_done =>w_write_done
		  );



cop3: datamux  -- data pins
	port map(iv_8bits_in =>data_t_datamux,
			clock=>clk,
		ov_8bits_out=>data_f_datamux,
		iv_slct=>slct,
		iov_data_inout=>io_data);



cop4: eventhandler 
	port map(clock =>clk_4MHz,
		reset => reset,
		i_uart_rx=>UART_RX_bits,
		i_sel=> slct,
		i_rxdone=> not(w_RX_done),
		--i_addr_done=>,
		i_read_done=>w_read_done,
		i_write_done=>w_write_done,
		o_read =>w_startread,
		o_write=>w_startwrite,
		o_addressout=>b_eventhandler_address);


cop5: frequency_divider 
  Port map(clk    =>clk,
       reset =>reset,
		 clock1 =>clk_4MHz);




cop6: rw_mux 
	port map(slct =>slct,
		wr_OE =>w_wr_OE,
		wr_WE =>w_wr_WE,
		wr_CE =>w_wr_CE,
		re_OE =>w_re_OE,
		re_WE =>w_re_WE,
		re_CE =>w_re_CE,
		out_OE =>OE,
		out_WE =>WE,
		out_CE =>CE);


cop7: UART_TX 
  generic map(
    g_CLKS_PER_BIT => c_CLKS_PER_BIT
     -- Needs to be set correctly
    )
  port map(
    i_Clk      =>clk_4MHz,
    i_TX_DV     =>w_TX_DV,
    i_TX_Byte   =>UART_TX_bits,
    o_TX_Active =>TXactive,
    o_TX_Serial =>UART_TXser,
    o_TX_Done   =>w_TX_done
    );


cop8: UART_RX 
  generic map(
    g_CLKS_PER_BIT => c_CLKS_PER_BIT
     -- Needs to be set correctly
    )

  port map(
    i_Clk       =>clk_4MHz,
    i_RX_Serial =>UART_RXser,
    o_RX_DV     =>w_RX_DV,
    o_RX_Byte   =>UART_RX_bits,
	 
	o_RX_done   =>w_RX_done -- added this
    );

cop9: addressmux
    Port map( slct => slct,
           iv_rdaddress =>b_readaddress,
           iv_wraddress =>b_writeaddress,
           ov_address_out => o_Address);	


RXactive <= w_RX_done;
end Behavioral;

