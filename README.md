# FPGA Chronometer - Cyclone I

**Author:** Alejandro Mañas  
**Board:** Altera Cyclone I (EP1C3T144)  
**Language:** VHDL

## Description
This is a configurable digital chronometer **implemented entirely from scratch** in VHDL for an FPGA. It uses a 50 MHz clock and displays the time on four 7-segment displays.

The main feature is the **Flag Mode** (Lap time): you can freeze the number on the display to write it down, but the counter continues running in the background. When you release the button, the time "jumps" to the real current time.

## How it works (Demo)
Here is the board working. You can see the count, the reset, and the flag functionality (freezing the display).

![Chronometer Demo](img/demo.gif)

## Smart Display Logic (Auto-Range)
A key feature I designed is the complete independence between the **Internal Counter Digits** and the **Physical Displays**.

* **Dynamic Windowing:** If the internal counter is configured to have huge numbers (e.g., 8 or 100 digits) but the board only has 4 displays, my logic automatically **shifts the view** to show the most significant active digits.
* **Floating Decimal Point:** The decimal point is not fixed to a physical LED. It moves dynamically with the numbers so it always stays in the correct mathematical position, even when the display shifts.

## Configuration (Generics)
My code is designed to be easily adaptable by changing the `GENERIC` constants in the top-level file:

* **Clock Frequency (`FREQ_CLK`):** Set to 50 MHz by default, but adaptable to other boards.
* **Counting Precision (`FREQ_COUNT`):** Defines the counting speed. Designed to work with **powers of 10** (e.g., 100 Hz, 1000 Hz) to maintain base-10 logic.
* **True Scalability (`DIGIT_NUM` & `DISPL_NUM`):**
    * **Internal Counter:** The number of BCD digits (`DIGIT_NUM`) is unlimited.
    * **Chronometer Logic:** The main controller is also **hardware-agnostic**. It can manage any number of displays (`DISPL_NUM`). If you set it to 8 or 16 displays, the logic will automatically format the data for that width.
    * **Hardware Limitation:** The current `Disp7Seg_Controller` module is the only component limited to 4, strictly because the physical Cyclone I board only has 4 displays.
    * *Adaptability:* If you replace the 7-segment driver with one designed for a bigger board (e.g., 8 displays), my `Chronometer_Controller` will adapt instantly just by changing the `DISPL_NUM` generic, without rewriting the logic.

## Controls
* **Reset (Button 1):** Asynchronous reset. Puts the counter to 0000.
* **Pause (Button 2):** Stops the count completely.
* **Flag (Button 3):** Freezes the display value. The internal counter keeps counting.

## Modules
I developed the project dividing it into these custom VHDL files:

1.  **Chronometer_Controller:** The main file. It contains the state machine and the **smart windowing logic** to map the large internal counter to the small physical display.
2.  **X_Digits_BCD_Counter:** It counts in BCD format (multi-digit). It is configurable (you can change the number of digits).
3.  **BCD_Counter:** The basic unit that counts from 0 to 9. It is used inside the X_Digits counter.
4.  **Disp7Seg_Controller:** Controls the 4 displays using multiplexing. I designed this module to match the board's 4-digit physical interface.
5.  **Disp7Seg_Driver:** Decodes the number to the 7-segment format.
6.  **Debouncer:** Filters the noise from the mechanical buttons.

## Simulation
I simulated all the modules before testing them on the board to ensure the logic was correct.
You can check the **SIMULATION_REPORT.md** file in this repository to see the waveforms and the verification steps.
