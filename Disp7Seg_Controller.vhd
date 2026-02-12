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
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
-- Entity declaration
----------------------------------------------------------------------------------
entity Disp7Seg_Controller is
    generic (
		FREQ_CLK  :  integer := 50000000;  -- CLK frequency of the FPGA
		Refresh_Rate   :  integer := 60        -- Refresh Rate of the 7 seg Displays
	);
    
    port(
		nrst         : in  std_logic; 					                -- Not Reset
		clk          : in  std_logic;              		      -- Clock 
		val_in       : in  std_logic_vector(15 downto 0);  -- Input value 
		dp_pos_in    : in  std_logic_vector (1 downto 0);  -- Dot Point Position Output
		dp_pos_true  : in  std_logic;                      -- '0' to do not show any dot point
		bl_disp_in   : in  std_logic_vector (3 downto 0);  -- Array of blank screens
		
		dp_out       : out std_logic;                      -- Dot Point Position Output
		disp_sel     : out std_logic_vector (3 downto 0);  -- Display select
		segment_val  : out std_logic_vector (6 downto 0)   -- Value to show on the Display
        
    );
end entity Disp7Seg_Controller;

----------------------------------------------------------------------------------
-- Architecture declaration
----------------------------------------------------------------------------------
architecture behavioral of Disp7Seg_Controller is 
	-- DECLARATION OF CONSTANTS
	constant disp_num		   : integer := 4;
	constant Count_Max 		   : integer := FREQ_CLK / (disp_num * Refresh_Rate);
	-- DECLARATION OF THE SIGNAL COUNTER
	signal timer_refresh_rate  : integer := 0;
	signal val_intern  : std_logic_vector(3 downto 0);  -- Internal value to be displayed
	-- FLIP FLOP TO SAVE THE INPUT VALUES AND DOT POINT POSITION
	signal disp_val    : std_logic_vector(15 downto 0); -- Display values
	signal display_pos : unsigned (1 downto 0) := "00"; -- Display being used 
	signal dp_state    : std_logic;                     -- Dot point state
	-- BL DISP IN CONNECTION TO DRIVER
	signal bl_disp_in_aux : std_logic;
begin 
	process(clk, nrst)
	begin
	if(clk' event and clk = '1') then
		-- RESET
		if(nrst = '0') then
			timer_refresh_rate <= 0;
			disp_val <= val_in;
			display_pos <= "00";
			
		-- REFRESH RATE COUNTER
		elsif(timer_refresh_rate < Count_Max-1) then
			timer_refresh_rate <= timer_refresh_rate + 1;
		else  
			timer_refresh_rate <= 0;
			if not(display_pos < 3)  then
				disp_val <= val_in;
			end if;
			display_pos <= display_pos + 1;
		end if;
		-- CHOOSE THE VALUE THAT THE ACTUAL DISPLAY WILL SHOW
		case display_pos is
			when "00" => val_intern <= disp_val  (3 downto 0); -- nothing nothing nothing number
			when "01" => val_intern <= disp_val  (7 downto 4); -- nothing nothing number nothing
			when "10" => val_intern <= disp_val (11 downto 8); -- nothing number nothing nothing
			when "11" => val_intern <= disp_val(15 downto 12); -- number nothing nothing nothing
			when others => val_intern <= x"8";
		end case;
	end if;
	end process;
	
	dp_state <= '1' when dp_pos_in = std_logic_vector(display_pos) and dp_pos_true = '1' else '0';
	
  ----------------------------------------------------------------------------------
  -- Connection with driver 
  ----------------------------------------------------------------------------------
	bl_disp_in_aux <= bl_disp_in(to_integer(display_pos)); -- Declaration of a static signal for the driver input
	
	u_driver : entity work.Disp7Seg_Driver
	port map(
		val_in      => val_intern,
		disp_in     => std_logic_vector(display_pos),
		dp_in       => dp_state,
		bl_disp     => bl_disp_in_aux,
		
		disp_sel    => disp_sel,
		segment_out => segment_val,
		dp_out      => dp_out
	);
	
end architecture behavioral; 
