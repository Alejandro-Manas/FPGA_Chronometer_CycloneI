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

## Configuration (Generics)
My code is designed to be easily adaptable by changing the `GENERIC` constants in the top-level file:

* **Clock Frequency (`FREQ_CLK`):** Set to 50 MHz by default, but adaptable to other boards.
* **Refresh Rate (`REFRESH_RATE`):** Controls how fast the displays switch (multiplexing).
* **Counting Precision (`FREQ_COUNT`):** Defines the counting speed. Designed to work with **powers of 10** (e.g., 100 Hz, 1000 Hz) to maintain base-10 logic.
* **Scalability (`DIGIT_NUM`):**
    * The core logic (`Chronometer_Controller` and `X_Digits_BCD_Counter`) is **fully scalable**. It can handle any number of digits (e.g., 6, 8, etc.) just by changing the generic value.
    * *Note:* The limitation to 4 digits comes from the physical board hardware. I wrote the `Disp7Seg_Controller` specifically to interface with these 4 physical displays, but my chronometer logic is ready for larger systems.

## Controls
* **Reset (Button 1):** Asynchronous reset. Puts the counter to 0000.
* **Pause (Button 2):** Stops the count completely.
* **Flag (Button 3):** Freezes the display value. The internal counter keeps counting.

## Modules
I developed the project dividing it into these custom VHDL files:

1.  **Chronometer_Controller:** The main file. It connects the buttons, the counter, and the display driver. It contains the state machine.
2.  **X_Digits_BCD_Counter:** It counts in BCD format (multi-digit). It is configurable (you can change the number of digits).
3.  **BCD_Counter:** The basic unit that counts from 0 to 9. It is used inside the X_Digits counter.
4.  **Disp7Seg_Controller:** Controls the 4 displays using multiplexing. I designed this module to match the board's 4-digit physical interface.
5.  **Disp7Seg_Driver:** Decodes the number to the 7-segment format.
6.  **Debouncer:** Filters the noise from the mechanical buttons.

## Simulation
I simulated all the modules before testing them on the board to ensure the logic was correct.
You can check the **SIMULATION_REPORT.md** file in this repository to see the waveforms and the verification steps.
