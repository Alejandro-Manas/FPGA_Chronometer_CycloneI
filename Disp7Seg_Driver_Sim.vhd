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

entity Disp7Seg_Driver_Sim is
end entity Disp7Seg_Driver_Sim; 

architecture sim of Disp7Seg_Driver_Sim is
  
signal val_in_t       :  std_logic_vector(3 downto 0) := x"0";
signal disp_in_t      :  std_logic_vector(1 downto 0) := "00";
signal dp_in_t        :  std_logic := '0';
signal bl_disp_t      :  std_logic := '0';

signal disp_sel_t     :  std_logic_vector(3 downto 0);
signal segment_out_t  :  std_logic_vector(6 downto 0);
signal dp_out_t       :  std_logic;

begin

  Disp7Seg_Driver_test : entity work.Disp7Seg_Driver
  port map(
    val_in      =>  val_in_t,
    disp_in     =>  disp_in_t,
    dp_in       =>  dp_in_t,
    bl_disp     =>  bl_disp_t, 

    disp_sel    =>  disp_sel_t, 
    segment_out =>  segment_out_t,  
    dp_out      =>  dp_out_t
  );

----------------------------------------------------------------------------------
-- Testing all the hexadecimal values
---------------------------------------------------------------------------------- 
  val_in_t <= x"0", x"1" after 10 ns, x"2" after 20 ns, x"3" after 30 ns, x"4" after 40 ns,
  x"5" after 50 ns, x"6" after 60 ns, x"7" after 70 ns, x"8" after 80 ns, x"9" after 90 ns,
  x"a" after 100 ns, x"b" after 110 ns, x"c" after 120 ns, x"d" after 130 ns, 
  x"e" after 140 ns, x"f" after 150 ns;     

----------------------------------------------------------------------------------
-- Testing the blank display functionality
----------------------------------------------------------------------------------
  bl_disp_t <= '1' after 160 ns, '0' after 170 ns;

----------------------------------------------------------------------------------
-- Testing the dot point functionality 
----------------------------------------------------------------------------------
  dp_in_t <= '1' after 180 ns, '0' after 190 ns;
  
----------------------------------------------------------------------------------
-- Testing the display switching functionality 
----------------------------------------------------------------------------------
  disp_in_t <= "01" after 200 ns, "10" after 210 ns, "11" after 220 ns, "00" after 230 ns;

end architecture sim;