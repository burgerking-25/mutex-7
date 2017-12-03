--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   08:12:14 11/12/2017
-- Design Name:   
-- Module Name:   C:/Xilinx/14.7/ISE_DS/ISE/bin/VHDL_Lab_Suite_SE/UART_sipo_ECNG3006/datamuxtb2.vhd
-- Project Name:  UART_sipo_ECNG3006
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: datamux
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
 
ENTITY datamuxtb2 IS
END datamuxtb2;
 
ARCHITECTURE behavior OF datamuxtb2 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT datamux
    PORT(
         iv_8bits_in : in  std_logic_vector(7 downto 0);
         clock : IN  std_logic;
         ov_8bits_out : out  std_logic_vector(7 downto 0);
         iv_slct : IN  std_logic_vector(1 downto 0);
         iov_data_inout : INOUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clock : std_logic := '0';
   signal ov_8bits_out : std_logic_vector(7 downto 0);-- := (others => '0');
   signal iv_slct : std_logic_vector(1 downto 0);-- := (others => '0');

	--BiDirs
   signal iov_data_inout : std_logic_vector(7 downto 0);

 	--Outputs
   signal iv_8bits_in : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: datamux PORT MAP (
          iv_8bits_in => iv_8bits_in,
          clock => clock,
          ov_8bits_out => ov_8bits_out,
          iv_slct => iv_slct,
          iov_data_inout => iov_data_inout
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		iv_slct <= "00";
		iv_8bits_in <= X"AA";
      wait for 100 ns;
		iv_slct <= "01";
		iv_8bits_in <= X"FF";
		wait for 100 ns;
		iv_slct <= "10";
		ov_8bits_out <= X"99";

      wait for 100 ns;
		iv_slct <= "00";
		iv_8bits_in <= X"99";

      -- insert stimulus here 

      wait;
   end process;

END;
