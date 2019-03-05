# Lab 5 CPU design Part 2

We created a ram module and  a rom module and instantiated the rom module with the given .coe file. We also made a memoryInt.vhd file to instantiate the memory elements and port map all the ports of the memory and the alu we designed in lab 4. memoryInt takes 2 input clock and reset. We then tested the program after setting memoryInt.vhd as the top level and simulated it with the loaded program.We also created a fully automated testbench to directly set and reset during the first clock cycle and then run the program.

*author:- Mayank & Medha*
