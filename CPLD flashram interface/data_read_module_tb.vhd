--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:24:28 11/12/2017
-- Design Name:   
-- Module Name:   C:/Xilinx/14.7/ISE_DS/ISE/bin/VHDL_Lab_Suite_SE/UART_sipo_ECNG3006/data_read_module_tb.vhd
-- Project Name:  UART_sipo_ECNG3006
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: data_read_module
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
 
ENTITY data_read_module_tb IS
END data_read_module_tb;
 
ARCHITECTURE behavior OF data_read_module_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT data_read_module
    PORT(
         clk : IN  std_logic;
         i_startread : IN  std_logic;
         reset : IN  std_logic;
         iv_19_bit : IN  std_logic_vector(18 downto 0);
         iv_data_f_ram : IN  std_logic_vector(7 downto 0);
         ov_data_t_uart : OUT  std_logic_vector(7 downto 0);
         ov_19_bit : OUT  std_logic_vector(18 downto 0);
         o_OE : OUT  std_logic;
         o_WE : OUT  std_logic;
         o_CE : OUT  std_logic;
         o_read_done : OUT  std_logic;
         o_TX_DV : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal i_startread : std_logic := '0';
   signal reset : std_logic := '0';
   signal iv_19_bit : std_logic_vector(18 downto 0) := (others => '0');
   signal iv_data_f_ram : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal ov_data_t_uart : std_logic_vector(7 downto 0);
   signal ov_19_bit : std_logic_vector(18 downto 0);
   signal o_OE : std_logic;
   signal o_WE : std_logic;
   signal o_CE : std_logic;
   signal o_read_done : std_logic;
   signal o_TX_DV : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: data_read_module PORT MAP (
          clk => clk,
          i_startread => i_startread,
          reset => reset,
          iv_19_bit => iv_19_bit,
          iv_data_f_ram => iv_data_f_ram,
          ov_data_t_uart => ov_data_t_uart,
          ov_19_bit => ov_19_bit,
          o_OE => o_OE,
          o_WE => o_WE,
          o_CE => o_CE,
          o_read_done => o_read_done,
          o_TX_DV => o_TX_DV
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	
 	address: process
	begin
	   iv_19_bit <= "1100100111110011011";
		iv_data_f_ram <= "01101101" ;
		wait;
	end process;

   -- Stimulus process
   stim_proc: process
   begin		
      reset <= '1';
      wait for 00 ns;	
		reset <= '0';

  
		i_startread <= '1';
		wait for clk_period;
		wait for clk_period;
		i_startread <= '0';
		wait;
		

      -- insert stimulus here 

      wait;
   end process;

END;
