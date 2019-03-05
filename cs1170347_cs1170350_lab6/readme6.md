# Lab 6 Loading the program on BASYS3 board

We extended the program of the lab5 to include an FSM with different states so that different programs can be loaded on the memory at the same time and then the result can be displayed through the leds. Since there are 16 leds, we control showing the upper half and lower half through a switch and loading the program counter upon reset to a certain value.<br>
x000-R0<br>
x001-R1<br>
x010-R2<br>
x011-R3<br>
x100-program address<br>
x101-instruction<br>
x110-memory data<br>
*The first bit is 0 for the lower half and 1 for upper half.<br>

Also, the user can input the multiple programs at once and the program counter value which would load upon reset using 3 switches.


### Author- Medha & Mayank