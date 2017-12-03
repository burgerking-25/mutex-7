--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:30:54 11/16/2017
-- Design Name:   
-- Module Name:   C:/Users/Luther Jn. Baptiste/Documents/UART_sipo_ECNG3006/UART_sipo_maintb.vhd
-- Project Name:  UART_sipo_ECNG3006
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: UART_sipo_main
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY UART_sipo_maintb IS
END UART_sipo_maintb;
 
ARCHITECTURE behavior OF UART_sipo_maintb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT UART_sipo_main
    PORT(
         o_Address : OUT  std_logic_vector(18 downto 0);
         io_data : INOUT  std_logic_vector(7 downto 0);
         OE : OUT  std_logic;
         WE : OUT  std_logic;
         CE : OUT  std_logic;
         UART_RXser : IN  std_logic;
         clk : IN  std_logic;
         reset : IN  std_logic;
         slct : IN  std_logic_vector(1 downto 0);
         UART_TXser : OUT  std_logic;
         TXactive : OUT  std_logic;
         RXactive : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal UART_RXser : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal slct : std_logic_vector(1 downto 0) :="10";--:= (others => '0');

	--BiDirs
   signal io_data : std_logic_vector(7 downto 0):="10111011";

 	--Outputs
   signal o_Address : std_logic_vector(18 downto 0);
   signal OE : std_logic;
   signal WE : std_logic;
   signal CE : std_logic;
   signal UART_TXser : std_logic;
   signal TXactive : std_logic;
   signal RXactive : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	constant c_BIT_PERIOD: time := 80 ns;
	  procedure UART_WRITE_BYTE (
    i_data_in       : in  std_logic_vector(7 downto 0);
    signal o_serial : out std_logic) is
  begin

    -- Send Start Bit
    o_serial <= '0';
    wait for c_BIT_PERIOD;

    -- Send Data Byte
    for ii in 0 to 7 loop
      o_serial <= i_data_in(ii);
      wait for c_BIT_PERIOD;
    end loop;  -- ii

    -- Send Stop Bit
    o_serial <= '1';
    wait for c_BIT_PERIOD;
  end UART_WRITE_BYTE;

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: UART_sipo_main PORT MAP (
          o_Address => o_Address,
          io_data => io_data,
          OE => OE,
          WE => WE,
          CE => CE,
          UART_RXser => UART_RXser,
          clk => clk,
          reset => reset,
          slct => slct,
          UART_TXser => UART_TXser,
          TXactive => TXactive,
          RXactive => RXactive
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      reset<= '1';
      wait for 100 ns;
		UART_RXser <= '1';
		reset<= '0';

      wait for clk_period*10;
		slct <= "10";
		io_data <= "10111011";
		wait until rising_edge(clk);
		UART_WRITE_BYTE(X"3F", UART_RXser);
		wait until rising_edge(clk);
      -- insert stimulus here 

      wait;
   end process;

END;
