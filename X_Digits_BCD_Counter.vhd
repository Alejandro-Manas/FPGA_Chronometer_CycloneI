----------------------------------------------------------------------------------
-- Module:      X_Digits_BCD_Counter
-- Author:      Alejandro Mañas
-- Target:      Cyclone I (Legacy)
-- Description:
--    Module to count on BCD format
--    It combined a configurable number of BCD_Counter modules to allow the count of bigger numbers
--    Configurable clock frequency
--    Configurable number of digits
--    Configurable counting frequency
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
-- Entity declaration
----------------------------------------------------------------------------------
entity X_Digits_BCD_Counter is
	generic(
	FREQ_CLK	  :	integer := 50000000;	 -- Frecuency of the input clock
	FREQ_COUNT	:	integer := 100;		      -- Frequency of count
	DIGIT_NUM	 :	integer := 6			       -- Number of displays
	);
	port(
	clk_in	:	in std_logic;
	nrst		 :	in std_logic;
	ena			 :	in std_logic;
	
	num_out		:	out std_logic_vector((4 * DIGIT_NUM - 1) downto 0)
	);
end entity X_Digits_BCD_Counter;

----------------------------------------------------------------------------------
-- Architecture declaration
----------------------------------------------------------------------------------
architecture behavioral of X_Digits_BCD_Counter is
	
	-- SIGNAL DECLARATION
  
	-- VECTOR OF CARRY BETWEEN MODULES
	signal   carry_signals	:	std_logic_vector ((DIGIT_NUM) downto 0) := (0 => '1', others => '0');
	
	-- CLOCK DIVIDER SIGNALS
	constant count_clk_MAX	:	integer := (FREQ_CLK / FREQ_COUNT) - 1;
	signal   count_clk		:	integer range 0 to count_clk_MAX:= 0;
	signal   clk_out		:	std_logic := '0';
	
begin 

----------------------------------------------------------------------------------
-- Logic to adapt the clock frequency to de count frequency
----------------------------------------------------------------------------------
	process(nrst, clk_in)
	begin
	if nrst = '0' then 
		count_clk <= 0;
		clk_out <= '0';
	elsif clk_in' event and clk_in = '1' and ena = '1'then
		if count_clk < count_clk_MAX then
			count_clk <= count_clk + 1;
			clk_out <= '0';
		else
			count_clk <= 0;
			clk_out <= '1';
		end if;
	end if;
	end process;
	
  ----------------------------------------------------------------------------------
  -- Connection with the BCD_Counter modules 
  ----------------------------------------------------------------------------------
	digits_boucle	:	for i in 0 to (DIGIT_NUM - 1) generate
	begin
	u_counter	:	entity work.BCD_Counter
		port map(
		clk		=>	clk_out,
		nrst	=>	nrst,
		c_in	=>	carry_signals(i),
		
		c_out	=>	carry_signals(i + 1),
		num_out =>	num_out((4*i+3) downto (4*i))
		);
	end generate digits_boucle;

end architecture behavioral;

