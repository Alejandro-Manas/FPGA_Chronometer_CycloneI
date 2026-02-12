----------------------------------------------------------------------------------
-- Module:      BCD_Counter
-- Author:      Alejandro Mañas
-- Target:      Cyclone I (Legacy)
-- Description:
--    Module to count on BCD format
--    Can count up to nine
--    The modules can be connected to show number of more than one digit due to carry out and carry in output and input
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
-- Entity declaration
----------------------------------------------------------------------------------
entity BCD_Counter is 
	port(
	clk     : in  std_logic;  					-- Clock
	nrst    : in  std_logic;  					-- Not Reset 
	c_in    : in  std_logic;   					-- Carry in
	 
	c_out   : out std_logic;    				-- Carry Out
	num_out : out std_logic_vector(3 downto 0)  -- Number Counter 
	);
end entity BCD_Counter;

----------------------------------------------------------------------------------
-- Architecture declaration
----------------------------------------------------------------------------------
architecture behavioral of BCD_Counter is
	signal internal_num : unsigned(3 downto 0) := x"0";  -- Internal signal for the counter
begin
	----------------------------------------------------------------------------------
  -- Synchronous logic
  ----------------------------------------------------------------------------------
	process (nrst, clk)
	begin
	if nrst = '0' then -- Reset logic
		internal_num <= x"0";
		--c_out <= '0';
	elsif clk' event and clk = '1' then
		if internal_num < 9 and c_in = '1' then     -- Carry in logic 		    
			internal_num <= internal_num +1;
		elsif internal_num = 9 and c_in = '1' then  -- Restart digit once the maximum is reached
		  internal_num <= x"0";
		end if;
	end if;
	end process;

  ----------------------------------------------------------------------------------
  -- Asynchronous logic
  ----------------------------------------------------------------------------------	
	c_out <= '1' when (internal_num = 9 and c_in = '1') else '0'; -- Carry out logic

  ----------------------------------------------------------------------------------
  -- Output assignments
  ----------------------------------------------------------------------------------	
	num_out <= std_logic_vector(internal_num);
end architecture behavioral;
			