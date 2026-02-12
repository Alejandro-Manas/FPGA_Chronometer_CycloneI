----------------------------------------------------------------------------------
-- Module:      BCD_Counter_Sim
-- Author:      Alejandro Mañas
-- Target:      Cyclone I
-- Description:
--    Module to count on BCD format
--    Can count up to nine
--    The modules can be connected to show number of more than one digit due to carry out and carry in output and input
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BCD_Counter_Sim is 
end entity BCD_Counter_Sim;

architecture sim of BCD_Counter_Sim is

signal clk_t    : std_logic := '0';
signal nrst_t   : std_logic := '0';
signal c_in_t   : std_logic := '1';

signal c_out_t  : std_logic := '0';
signal num_out_t    : std_logic_vector (3 downto 0) := x"0";

begin 
  BCD_test  : entity work.BCD_Counter
  port map(
    clk     =>  clk_t,
    nrst    =>  nrst_t,
    c_in    =>  c_in_t,
    
    c_out   =>  c_out_t,
    num_out =>  num_out_t
  );

  clk_process : process --20 ns clk 50% DC
  begin
    wait for 10 ns;
    clk_t <= not clk_t;
  end process;

----------------------------------------------------------------------------------
-- Testing the output when it is counting
---------------------------------------------------------------------------------- 
  c_in_t <= '0' after 300 ns;
  
----------------------------------------------------------------------------------
-- Testing the reset functionality
----------------------------------------------------------------------------------  
  nrst_t <= '1' after 80 ns;

end architecture sim;
