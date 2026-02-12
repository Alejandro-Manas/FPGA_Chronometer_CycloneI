----------------------------------------------------------------------------------
-- Module:      Disp7Seg_Controller
-- Author:      Alejandro Mañas
-- Target:      Cyclone I (Legacy)
-- Description: 
--    Rotates between the display to show digits on all the displays simultaneously 
--    Configurable Clock Frequency
--    Configurable refresh rate for the displays
--    Driver_Freq = Disp_num*Refresh_Rate
--    Counter_Max = CLK / Driver_Freq (To divide the frequency)
--    Designed for four displays
-- Simulation Purpose:
--    Ensure the correct functionality of the blank display function, that it can show different values in the displays and that they are refreshed at the desired frequency
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Disp7Seg_Controller_Sim is
end entity Disp7Seg_Controller_Sim;

architecture sim of Disp7Seg_Controller_Sim is

signal nrst_t : std_logic := '0';
signal clk_t : std_logic := '1';
signal val_in_t : std_logic_vector(15 downto 0) := x"0000";
signal dp_pos_in_t : std_logic_vector(1 downto 0) := "00";
signal dp_pos_true_t : std_logic := '1';
signal bl_disp_in_t : std_logic_vector(3 downto 0) := x"0";

signal dp_out_t : std_logic;
signal disp_sel_t : std_logic_vector(3 downto 0);
signal segment_val_t : std_logic_vector(6 downto 0);

begin 

  Disp7Seg_Controller : entity work.Disp7Seg_Controller
  generic map(
  		FREQ_CLK      =>  50000000,
		Refresh_Rate  =>  12500000   
  )
  port map(
    nrst => nrst_t,
    clk => clk_t,
    val_in => val_in_t,
    dp_pos_in => dp_pos_in_t,
    dp_pos_true => dp_pos_true_t,
    bl_disp_in => bl_disp_in_t,
    dp_out => dp_out_t,
    disp_sel => disp_sel_t,
    segment_val => segment_val_t 
  );
  
  clk_process : process
  begin
    wait for 10 ns;
    clk_t <= not clk_t;
  end process;
  
----------------------------------------------------------------------------------
-- Making the group of display move some "F" between each other to see that the display work as intended
-- Making sure that the blank display functionality works as intended
-- Confirming that the dp_position gets updated
---------------------------------------------------------------------------------- 
  
  nrst_t <= '1' after 40 ns, '0' after 940 ns;
  val_in_t <= x"000F" after 200 ns, x"00FF" after 280 ns, x"0FF0" after 360 ns, x"F00F" after 440 ns;
  dp_pos_in_t <= "01" after 280 ns, "10" after 360 ns, "11" after 440 ns, "00" after 520 ns, "01" after 840 ns;
  bl_disp_in_t <= "0001" after 520 ns, "0010" after 600 ns, "0100" after 680 ns, "1000" after 760 ns,
                  "1001" after 840 ns;
  dp_pos_true_t <= '0' after 840 ns, '1' after 1000 ns;
                  
end architecture sim;