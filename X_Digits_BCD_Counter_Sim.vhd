----------------------------------------------------------------------------------
-- Module:      X_Digits_BCD_Counter_Sim
-- Author:      Alejandro Mañas
-- Target:      Cyclone I (Legacy)
-- Description: 
--    Module to count on BCD format
--    It combined a configurable numnber of BCD_Counter modules to allow the count of bigger numbers
--    Configurable clock frequency
--    Confiurable number of digits
--    Configurable counting frequency
-- Simulation Purpose:
--    Make sure that the system counts correctly and confirm that the enable and reset inputs do what is intended
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity X_Digits_BCD_Counter_Sim is
end entity X_Digits_BCD_Counter_Sim;

architecture sim of X_Digits_BCD_Counter_Sim is

  signal clkin_in     :  std_logic := '0';
  signal nrst_in      :  std_logic := '0';
  signal ena_in       :  std_logic := '0';

  signal numout_out   :  std_logic_vector((4 * 6 -1) downto 0);
  
  constant FREQ_COUNT : integer := 12500000;

begin 
 
  X_Digits_Counter_Test : entity work.X_Digits_BCD_Counter
  generic map(
  FREQ_COUNT => FREQ_COUNT
  )
  port map(
    clk_in   =>  clkin_in,
    nrst     =>  nrst_in,
    ena      =>  ena_in,
    num_out  =>  numout_out
  );

  clk_process : process -- 20 ns clock 
  begin
    wait for 10 ns;
    clkin_in <= not clkin_in; 
  end process;

----------------------------------------------------------------------------------
-- Ensuring the nrst functionality
-- Confirm that tte enable input works as a puse/continue button
-- Confirm ttat even in the critical situations the comunications between BCD_Counter modules works great
-- The critical situations in the communications are the c_out so the test disables the enable when the counter have a eight and a nine to ensure that the carrys works
----------------------------------------------------------------------------------   
  nrst_in <= '1' after 35 ns, '0' after 190 ns, '1' after 200 ns;
  
  ena_in <= '1' after 80 ns, '0' after 160 ns, '1' after 200 ns, '0' after 845 ns,
  '1' after 925 ns, '0' after 2600 ns, '1' after 2700 ns;
   
end architecture sim;