--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   08:09:45 11/13/2017
-- Design Name:   
-- Module Name:   C:/Xilinx/14.7/ISE_DS/ISE/bin/VHDL_Lab_Suite_SE/UART_sipo_ECNG3006/rw_muxtb.vhd
-- Project Name:  UART_sipo_ECNG3006
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: rw_mux
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
 
ENTITY rw_muxtb IS
END rw_muxtb;
 
ARCHITECTURE behavior OF rw_muxtb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT rw_mux
    PORT(
         slct : IN  std_logic_vector(1 downto 0);
         wr_OE : IN  std_logic;
         wr_WE : IN  std_logic;
         wr_CE : IN  std_logic;
         re_OE : IN  std_logic;
         re_WE : IN  std_logic;
         re_CE : IN  std_logic;
         out_OE : OUT  std_logic;
         out_WE : OUT  std_logic;
         out_CE : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal slct : std_logic_vector(1 downto 0) := (others => '0');
   signal wr_OE : std_logic := '0';
   signal wr_WE : std_logic := '0';
   signal wr_CE : std_logic := '0';
   signal re_OE : std_logic := '0';
   signal re_WE : std_logic := '0';
   signal re_CE : std_logic := '0';

 	--Outputs
   signal out_OE : std_logic;
   signal out_WE : std_logic;
   signal out_CE : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: rw_mux PORT MAP (
          slct => slct,
          wr_OE => wr_OE,
          wr_WE => wr_WE,
          wr_CE => wr_CE,
          re_OE => re_OE,
          re_WE => re_WE,
          re_CE => re_CE,
          out_OE => out_OE,
          out_WE => out_WE,
          out_CE => out_CE
        );

   -- Clock process definitions
--   <clock>_process :process
--   begin
--		<clock> <= '0';
--		wait for <clock>_period/2;
--		<clock> <= '1';
--		wait for <clock>_period/2;
--   end process;
-- 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
			
		   wr_OE <= '1';
         wr_WE <= '0';
         wr_CE <= '1';
			re_OE <= '1';
         re_WE <= '1';
         re_CE <= '0';

      wait for clock_period*10;
		
			slct <= "00";
			wait for 100 ns;
			slct <= "01";
			wait for 100 ns;
			slct <= "10";
			wait for 100 ns;

      -- insert stimulus here 

      wait;
   end process;

END;
