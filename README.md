# FPGA Chronometer - Cyclone I

**Author:** Alejandro Mañas  
**Board:** Altera Cyclone I (EP1C3T144)  
**Language:** VHDL

## Description
This is a configurable digital chronometer designed for an FPGA. It uses a 50 MHz clock and displays the time on four 7-segment displays.

The main feature is the **Flag Mode** (Lap time): you can freeze the number on the display to write it down, but the counter continues running in the background. When you release the button, the time "jumps" to the real current time.

## How it works (Demo)
Here is the board working. You can see the count, the reset, and the flag functionality (freezing the display).

![Chronometer Demo](img/VID_20260211_001034-ezgif.com-optimize.gif)

## Controls
* **Reset (Button 1):** Reset. Puts the counter to 0000.
* **Pause (Button 2):** Stops the count completely.
* **Flag (Button 3):** Freezes the display value. The internal counter keeps counting.

## Modules
The project is divided into these VHDL files:

1.  **Chronometer_Controller:** The main file. It connects the buttons, the counter, and the display driver. It contains the state machine.
2.  **X_Digits_BCD_Counter:** It counts in BCD format. It is configurable (you can change the number of digits).
3.  **Disp7Seg_Controller:** Controls the 4 displays using multiplexing (refresh rate is configurable).
4.  **Disp7Seg_Driver:** Decodes the number to the 7-segment format.
5.  **Debouncer:** Filters the noise from the mechanical buttons.

## Simulation
I simulated all the modules before testing them on the board to ensure the logic was correct.
You can check the **SIMULATION_REPORT.md** file in this repository to see the waveforms and the verification steps.
