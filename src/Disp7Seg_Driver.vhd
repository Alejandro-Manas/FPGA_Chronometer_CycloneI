----------------------------------------------------------------------------------
-- Module:      Disp 7 Seg Driver
-- Author:      Alejandro Mañas
-- Target:      Cyclone I (Legacy)
-- Description: 
--    Transform 4 bits vector into an hexadecimal value shown on a 7 segment display
--    Includes a bit to control  the dot point state
--    Includes a bit to enable a blank display
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Disp7Seg_Driver is
    port(
        val_in       : in  std_logic_vector(3 downto 0);  -- Value Input
        disp_in      : in  std_logic_vector(1 downto 0);  -- Diplay Select Input 
        dp_in        : in  std_logic;                     -- Dot Point Input (positive logic)
        bl_disp      : in  std_logic;                     -- Blank display
           
        disp_sel     : out std_logic_vector(3 downto 0);  -- Display Select Output 
        segment_out  : out std_logic_vector(6 downto 0);  -- LED states output
        dp_out       : out std_logic					                 -- Dot Point Output (negative logic)
		-- Led A, LED B, LED C, LED D, LED E, LED F, LED G, DP = point between numbers
    );
end entity Disp7Seg_Driver;


architecture behavioral of Disp7Seg_Driver is 
	signal temp_segment : std_logic_vector(6 downto 0);
begin 
  
  -- --------------------------------------------------------------------------
  -- Display Multiplexer to select which display will be used
  -- --------------------------------------------------------------------------
	with disp_in select
		disp_sel <= "1110" when "00",
				    "1101" when "01",
				    "1011" when "10",
				    "0111" when "11",
				    "1111" when others;

  -- --------------------------------------------------------------------------
  -- Truth table to transform the number from hexadecimal to 7 Segment Display
  -- --------------------------------------------------------------------------
	with val_in select
		temp_segment <= "0000001" when "0000", -- 0
				 	    "1001111" when "0001", -- 1
				 	    "0010010" when "0010", -- 2
					    "0000110" when "0011", -- 3
					    "1001100" when "0100", -- 4
					    "0100100" when "0101", -- 5
					    "0100000" when "0110", -- 6 
					    "0001111" when "0111", -- 7
					    "0000000" when "1000", -- 8
					    "0001100" when "1001", -- 9
					   
					    "0001000" when "1010", -- A
					    "1100000" when "1011", -- b
					    "0110001" when "1100", -- C
					    "1000010" when "1101", -- d
					    "0110000" when "1110", -- E
					    "0111000" when "1111", -- F
					    
					    "1111111" when others;
					    				    
	-- --------------------------------------------------------------------------
  -- Output Logic with blank display incorporated
  -- --------------------------------------------------------------------------  
	segment_out <= temp_segment when bl_disp = '0' else "1111111";
		
	-- --------------------------------------------------------------------------
  -- Inversion of the dot point logic
  -- --------------------------------------------------------------------------
	dp_out <= not dp_in;
end architecture behavioral;
