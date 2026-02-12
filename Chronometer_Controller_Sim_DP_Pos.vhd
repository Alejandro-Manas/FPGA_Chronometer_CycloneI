----------------------------------------------------------------------------------
-- Module:      Chronometer_Controller_Sim_DP_Pos
-- Author:      Alejandro Mañas
-- Target:      Cyclone I (Legacy)
-- Description: 
--    Configurable number of displays (fixed to four by the controller of the seven segment displays)
--    Configurable number of BCD digits
--    Configurable frequency for the BCD counter. Designed to be used with powers of 10
--    Configurable waiting time for the debouncer
--    Configurable refresh rate for the displays
-- Simulation Purpose:
--    Ensure the correct functioning of the dot point position on the screen by counting until it need to move one position to the right
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Chronometer_Controller_Sim_DP_Pos is 
end entity Chronometer_Controller_Sim_DP_Pos;

architecture sim of Chronometer_Controller_Sim_DP_Pos is

signal nrst_t : std_logic := '0';
signal clk_t  : std_logic := '0';

signal pause_button_t : std_logic := '0';
signal flag_button_t  : std_logic := '0';

signal dp_state_t : std_logic;
signal disp_val_t : std_logic_vector(6 downto 0);
signal disp_sel_t : std_logic_vector(3 downto 0);

constant FREQ_COUNT   : integer := 10000;
constant WAIT_TIME    : integer := 2;
constant REFRESH_RATE : integer := 1000000;

begin
  Chronometer_Controller : entity work.Chronometer_Controller
  generic map(
  FREQ_COUNT     => FREQ_COUNT,
  WAIT_TIME     => WAIT_TIME,
  REFRESH_RATE  => REFRESH_RATE
  ) 
  port map(
    nrst => nrst_t,
    clk  => clk_t,
    
    pause_button => pause_button_t,
    flag_button  => flag_button_t,
    
    dp_state => dp_state_t,
    disp_val => disp_val_t,
    disp_sel => disp_sel_t
  );
  
  clk_process : process
  begin
    wait for 10 ns;
    clk_t <= not clk_t;
  end process;

----------------------------------------------------------------------------------
-- Testing the rest of the functionalities. They will be tested and observed in detail on another simulation
---------------------------------------------------------------------------------- 
  nrst_t <= '1' after 50 ns, '0' after 1100 ns, '1' after 1200 ns;
  pause_button_t <= '1' after 100 ns, '0' after 200 ns, '1' after 1300 ns, '0' after 1350 ns,
                    '1' after 8000 ns, '0' after 8050 ns, '1' after 10000 ns, '0' after 10050 ns; 
  flag_button_t <= '1' after 650 ns, '0' after 1000 ns, '1' after 2000 ns, '0' after 2100 ns,
                  '1' after 5000 ns, '0' after 5050 ns, '1' after 6000 ns, '0' after 6050 ns;

end architecture sim;
