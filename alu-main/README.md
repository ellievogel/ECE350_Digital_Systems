# ALU

## Ellie Vogel

## This design utilizes a main alu.v file to analyze an opcode and produce the desired result. The ALU takes in data operands A and B, as well as an opcode and shift amount. It returns the data result as well as a true/false result for whether the inputted values are equal, or if A is greater than B. Finally, it indicates whether or not overflow has occured.

## And

### (Found in and_32_bits.v) An and gate is performed on each bit in A and B, and the module outputs the result.

## Or

### (Found in or_32_bits.v) This operation takes in A and B as inputs, applies an or gate to each bit, and outputs the result.

## Adder

### The adder is a two-level carry look ahead adder, which integrates 4 8-bit CLA blocks, found in cla_block.v. To use this adder, I first utilize my 32-bit and gate to generate the "generate" signals, and my 32-bit or gate to generate the "propogate" signals for each bit in A and B. The CLA blocks take in 8 bits of A, B, the relevant calculated propogate signals, the relevant calculated generate signals, and a Cin. Each block produces a result as well as the generate and propogate signals for that block. cla.v takes in A, B, and Cin and outputs a sum, S, a carry out, Cout, and an overflow bit. It does this by utilizing recursive logic, as outlined in a two-level look ahead adder.

## Subtract

### In order to subtract, I utilized 2s complement arithmetic to be able to use the adder I had built. In order to subtract B from A, I first inverted B using not.v, which simply uses a not gate for each bit in B and returns the result. I then set Cin to 1 in order to add 1 to the result, then sent A and the inverted B to my CLA.

## Shifters

### There are two barrel shifters in this codebase, a left logical shift and a right arithmetic shift. Both shifters take in an input and a shift amount, outputting the shifted bits. They complete the shift by shifting the bits by 1, 2, 4, 8, and 16 spots, then utilizing 2 input muxes to decide whether each respective shift should occur. By doing it this way, any shift within the range of the shift amount bits can be performed.

## Comparators

### An xor gate is used to determine whether or not A is less than B. This is a result of the truth table for less than, which shows that for the 0, 0 case and 1, 1 case the output should be 0; the 0, 1 and 1, 0 cases output a 1. The inputs are the most significant bit of the sum of A and B and the overflow bit. In order to see whether or not A and B are equal, we check whether or not any bit in the result of subtraction is a 1, indicating that the amount is non-zero. By doing it this way, only a simple or gate is required.

## Bugs

### My ALU appears to pass all test cases, so there are not any noticeable bugs in the program.
