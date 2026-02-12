----------------------------------------------------------------------------------
-- Module:      Chronometer_Controller
-- Author:      Alejandro Mañas
-- Target:      Cyclone I (Legacy)
-- Description: 
--    Configurable number of displays (fixed to four by the controller of the seven segment displays)
--    Configurable number of BCD digits
--    Configurable frequency for the BCD counter. Designed to be used with powers of 10
--    Configurable waiting time for the debouncer
--    Configurable refresh rate for the displays
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
-- Entity declaration
----------------------------------------------------------------------------------
entity Chronometer_Controller is
  generic(
    DIGIT_NUM	    :	integer := 6;	      -- Number of digits of the BCD counter
    DISPL_NUM     : integer := 4;       -- Number of 7 segment display that will be available
    FREQ_COUNT     : integer := 1000;   -- counting frequency for the BCD counter(Hz)
    WAIT_TIME     : integer := 100000;  -- Filter window for the debouncer
    REFRESH_RATE  : integer := 1000     -- Refresh rate of the 7 segments display
  );
  port(
    -- Global clk and nrst signals
    nrst  : in std_logic; -- Entrada a la FPGA mediante boton 
    clk   : in std_logic; -- Conexion al reloj interno de la FPGA
    
    -- Input Controll Signals to be used with a debouncer
    pause_button  : in std_logic; -- Controlled with a button of the FPGA 
    flag_button   : in std_logic; -- Controlled with a button of the FPGA
    
    -- Signals to controll the 7 Segment Display (nrts and clk already declared)
    dp_state : out std_logic;
    disp_val : out std_logic_vector(6 downto 0);
    disp_sel : out std_logic_vector(3 downto 0)
    );
end entity Chronometer_Controller;

----------------------------------------------------------------------------------
-- Architecture declaration
----------------------------------------------------------------------------------
architecture behavioral of Chronometer_Controller is
  
  ---------------------------------------------------------------------------------- 
  -- SIGNAL DECLARATION
  ----------------------------------------------------------------------------------
  
  -- Auxiliary signals
  signal ena_1     : std_logic;        -- Enable signal that deactivates when the limit is reached
  signal ena_2    : std_logic := '0';  -- Enable signal connected to the debouncer start button
  signal ena_case : std_logic := '1';  -- Enable signal to ensure that the chronometer is paused when restarted. It activate and deactivate a not door into the ena_2 signal
  
  -- Signals to controll X Digits BCD Counter 
  signal ena                  : std_logic;                                    -- Enable signal controlled by ena_1, ena_2 and ena_case
  signal num_counter          : std_logic_vector((DIGIT_NUM*4 - 1) downto 0); -- Signal to enable the counter to count on the background while the flag state is active
  signal num_counter_bounded : std_logic_vector(15 downto 0);                -- Bounded signal of the BCD counter. It is bounded to the number of digits of the 7 segment display
  
  signal count_max            : std_logic_vector((DIGIT_NUM*4 - 1) downto 0); -- Signal to compare with the counter to know when te maximum count has been reached. It is a signal with as many 9 as DIGIT_NUM
  
  -- Signals to controll Disp 7 Seg Controller
  signal num_disp           : std_logic_vector(15 downto 0);            -- Signal with the actual number that is shown in the display. It is frozen when the flag state is on while the chronometer still runs on the background
  signal num_sel            : integer range 0 to (DIGIT_NUM - 1) := 1;  -- Signal used to select the most significative digits to be shown on the display
  signal dp_pos             : std_logic_vector(1 downto 0);             -- signal used to indicate de dot point position on the display runing on the background
  signal dp_pos_true        : std_logic := '0';                         -- signal used to indicate if the dot point have to appear on the display (deactivated at the beginning)
  signal dp_counter_pos     : integer := 0;                             -- signal used to indicate de dot point position on the digits of the counter
  signal bl_disp            : std_logic_vector(3 downto 0) := "0000";   -- Signal to indicate that we do not want any blank display
  signal dp_pos_disp        : std_logic_vector(1 downto 0);             -- signal used to indicate de dot point position on the display
  --outputs already declared as entity outputs
  
  -- Signals to controll internal logic
  signal flag_state       : std_logic;
  signal flag_state_aux   : std_logic;
  signal flag_state_case  : std_logic := '0';
  
----------------------------------------------------------------------------------
-- Function to determine the magnitude order of the count frequency
----------------------------------------------------------------------------------
  function dp_initial_pos (in_num : integer) return integer is
    variable aux : integer;
    variable res : integer := 0;
  begin
    aux := in_num;
    while aux >= 10 loop
      aux := aux/10;
      res := res + 1;
    end loop;
    return res;
  end function;

----------------------------------------------------------------------------------
-- Begening of the behavioral logic
----------------------------------------------------------------------------------
begin
  
  -- Determine the order of magnitude of the counter frequency  
  dp_counter_pos <= dp_initial_pos(FREQ_COUNT);
  
  ----------------------------------------------------------------------------------
  -- Function to add a signal of all nines to detemine the maximum count
  ----------------------------------------------------------------------------------
  nine_func : for i in 0 to (DIGIT_NUM - 1) generate
    count_max((4*i + 3) downto 4*i) <= x"9";
  end generate nine_func;
  
  ----------------------------------------------------------------------------------
  -- Connection with the work library modules 
  ----------------------------------------------------------------------------------
  -- Debouncer to controll the pause/continue
  debouncer_pause : entity work.Debouncer_Button
  generic map(
  WAIT_TIME => WAIT_TIME
  )
  port map(
  clk         => clk,
  button_in   => pause_button,
  
  button_out  => ena_2
  );
  
  -- Debouncer for the flag controll
  debouncer_flag : entity work.Debouncer_Button
  generic map(
  WAIT_TIME => WAIT_TIME
  )
  port map(
  clk         => clk,
  button_in   => flag_button,
  
  button_out  => flag_state_aux
  );
  
  -- Connections with the BCD counter
  BCD_Counter : entity work.X_Digits_BCD_Counter
  generic map(
  FREQ_COUNT => FREQ_COUNT
  )
  port map(
  clk_in  => clk,
  nrst    => nrst,
  ena     => ena,
  
  num_out => num_counter
  );
  
  -- Connections with the 7 segments display controller
  Disp_7_Seg : entity work.Disp7Seg_Controller
  generic map(
  Refresh_Rate => REFRESH_RATE
  )
  port map(
  nrst        => nrst, 
  clk         => clk,
  val_in      => num_disp,
  dp_pos_in   => dp_pos_disp,
  dp_pos_true => dp_pos_true,
  bl_disp_in  => bl_disp,
  
  dp_out      => dp_state,
  disp_sel    => disp_sel,
  segment_val => disp_val
  );
  
  ----------------------------------------------------------------------------------
  -- Synchronous logic
  ----------------------------------------------------------------------------------
  process(clk, nrst)
  begin
  if nrst = '0' then      -- Variable reset
    num_disp <= x"0000";
    num_sel <= 0;
    ena_1 <= '1';         -- Activation of the enable of the conter limit
    dp_pos_true <= '0';
    if ena_2 = '1' then   -- Ensure that after restarting the chronometer is paused
      ena_case <= '1';
    else
      ena_case <= '0';
    end if;
    
    if flag_state_aux = '1' then   -- Ensure that after restarting the chronometer deactivates the flag state
      flag_state_case <= '1';
    else
      flag_state_case <= '0';
    end if;
    
  elsif rising_edge(clk) then 
    ena_1 <= '1';                       -- Activation of the enable of the conter limit by default
    if flag_state = '0' then            -- In case that the flag state is activated the number showed on the display remains unchanged
      num_disp <= num_counter_bounded;
      dp_pos_disp <= dp_pos;
    end if;
    
    if num_counter >= count_max then     -- The chronometer is paused when teh limit is reached
      ena_1 <= '0';
    end if;
    
    if num_counter_bounded >= x"9999" then             --Adjustment of the most significant digits to be shown on the display 
      if num_sel < ((DIGIT_NUM) - DISPL_NUM) then 
        num_sel <= num_sel + 1;
      end if;
    end if;
    
    if (dp_counter_pos - num_sel) >= 0 and (dp_counter_pos - num_sel) <= 3 then
      dp_pos <= std_logic_vector(to_unsigned(dp_counter_pos - num_sel, 2));
      dp_pos_true <= '1';
    else
      dp_pos_true <= '0';
    end if;
      
  end if;
  end process;
  
  ----------------------------------------------------------------------------------
  -- Asynchronous logic
  ----------------------------------------------------------------------------------
  ena <= ena_1 and ena_2 when ena_case = '0' else
         ena_1 and not ena_2;

  flag_state <= flag_state_aux when flag_state_case = '0' else
                not flag_state_aux;
         
  num_counter_bounded <= num_counter((15 + num_sel*4) downto (num_sel*4));
   
end architecture behavioral;
