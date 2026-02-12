----------------------------------------------------------------------------------
-- Module:      Debouncer_Button (Toggle Version)
-- Author:      Alejandro Mañas
-- Target:      Cyclone I 
-- Description: 
--    Filters mechanical bounce from a push-button. 
--    Functions as a toggle switch: Pressing the button inverts the output state 
--    (0->1 or 1->0) once the signal is stable for WAIT_TIME cycles.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Debouncer_Button is
    generic(
    WAIT_TIME : integer := 100000     -- Filter window
   );
    port(
        clk         : in  std_logic;
        button_in   : in  std_logic;  -- Active High input
        button_out  : out std_logic 
    );
end entity Debouncer_Button;

architecture Behavioral of Debouncer_Button is
    constant COUNTER_MAX : integer := WAIT_TIME;
    
    signal button_state        : std_logic := '0';
    signal debounce_counter : integer range 0 to COUNTER_MAX;

begin 
    
    process(clk)
    begin
        if rising_edge(clk) then
          
-- --------------------------------------------------------------------------
-- Check button press + counter
-- -------------------------------------------------------------------------- 
            if (button_in = '1') and (debounce_counter < COUNTER_MAX) then
                debounce_counter <= debounce_counter + 1;
                
    
-- --------------------------------------------------------------------------
-- switch state when the filter time has passed
-- --------------------------------------------------------------------------           
                if debounce_counter = (COUNTER_MAX - 1) then
                    button_state <= not button_state;
                end if;

-- --------------------------------------------------------------------------
-- Reset counter if button is released
-- -------------------------------------------------------------------------- 
            elsif (button_in = '0') then 
                debounce_counter <= 0;
            end if;
        end if;
    end process;

-- --------------------------------------------------------------------------
-- Output assignments
-- -------------------------------------------------------------------------- 
    button_out <= button_state;
     
end architecture Behavioral;

