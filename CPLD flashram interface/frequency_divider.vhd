library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--entity frequency_divider is
--  Port(clk    : in std_logic;
--       reset  : in std_logic;
--		 clock1 : inout std_logic);
--end frequency_divider;

--architecture Behavioral of frequency_divider is
--begin
--1kHz clock signal
--  clk_1kHz : process(clk, reset)	 -- clock division by 10
--	 variable a1: integer range 0 to 4000;	  --10/2 = 5
--	 begin
--      if(reset ='1') then 
--		  a1:= 4000;
--		  clock1 <= '1';
--      elsif(clk'event and clk = '1') then 
--        a1 := a1 - 1;
--		end if;
--
--	   if(a1 = 0) then 
--		  a1:= 4000;
--		  clock1 <= not (clock1);
--      end if;
--   end process;
--end Behavioral;








--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
--
entity frequency_divider is
  Port(clk    : in std_logic;
       reset  : in std_logic;
		 clock1 : inout std_logic);
		-- clock2 : inout std_logic);
end frequency_divider;


architecture Behavioral of frequency_divider is
begin
--4MHz clock signal
  clk_1kHz : process(clk, reset)	 -- clock division by 2
	 variable a1: integer range 0 to 1;	  --8/8 = 1
	 begin
      if(reset ='1') then 
		  a1:= 1;
		  clock1 <= '1';
      elsif(clk'event and clk = '1') then 
        a1 := a1 - 1;
		end if;

	   if(a1 = 0) then 
		  a1:= 1;
		  clock1 <= not (clock1);
      end if;
   end process;

--1Hz clock signal
--  clk_1Hz : process(clk, reset)	 -- clock division by 10
--	 variable a2: integer range 0 to 20000000;	  --10/2 = 5
--	 begin
--      if(reset ='1') then 
--		  a2:= 20000000;
--		  clock2 <= '1';
--      elsif(clk'event and clk = '1') then 
--        a2 := a2 - 1;
--		end if;
--
--	   if(a2 = 0) then 
--		  a2:= 20000000;
--		  clock2 <= not (clock2);
--      end if;
--   end process;
end Behavioral;