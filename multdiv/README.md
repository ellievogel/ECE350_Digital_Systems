# MultDiv

## Ellie Vogel

## Multiplier

## Design Overview

This implementation uses a modified Booth's Multiplication Algorithm to perform signed 32-bit multiplication. The design processes two bits at a time, completing the multiplication operation in 16 cycles.

### Key Components

- **66-bit Combined Register**: Holds both the partial product (upper 33 bits) and the modified multiplier (lower 33 bits)
- **Booth Encoding Logic**: Uses 3 bits at a time to determine operations (add, subtract, shift, or do nothing)
- **Dual Carry-Lookahead Adders**: One for addition and one for subtraction operations
- **Iteration Counter**: 6-bit counter to track the 16 cycles needed for multiplication
- **Shift Units**: For both left shifting (multiplicand) and right shifting (partial product)

### Implementation Details

The multiplication process follows these steps:

1. Initial setup:

   - Load multiplier (operandB) into the lower bits of the combined register
   - Add an extra zero bit at the end for proper Booth encoding

2. For each iteration:

   - Examine 3 bits of the multiplier (Booth encoding)
   - Based on these bits:
     - 000 or 111: No operation (shift only)
     - 001 or 010: Add multiplicand
     - 011: Add shifted multiplicand
     - 100: Subtract shifted multiplicand
     - 101 or 110: Subtract multiplicand
   - Right shift the entire register by 2 bits

3. Final processing:
   - Extract result from bits [32:1] of the register
   - Check for overflow conditions

## Divider

### Design Overview

This implementation uses a non-restoring division algorithm to perform signed 32-bit division. The design employs a sequential approach that processes one bit per clock cycle, completing the division operation in 33 cycles.

### Key Components

- **64-bit Combined Register**: Holds both the remainder (upper 32 bits) and the developing quotient (lower 32 bits)
- **Carry-Lookahead Adder**: Used for addition/subtraction operations
- **Iteration Counter**: 6-bit counter to track the 33 cycles needed for division
- **Sign Handling Logic**: Converts operands to absolute values for processing and adjusts the final result's sign

### Implementation Details

The division process follows these steps:

1. Initial setup:

   - Convert both operands to positive numbers using 2's complement
   - Load dividend into lower 32 bits of the combined register
   - Clear upper 32 bits (remainder portion)

2. For each iteration:

   - Left shift the combined register by 1 bit
   - Compare the upper 32 bits (remainder) with the divisor
   - Subtract divisor from remainder if possible, restore if necessary
   - Set quotient bit based on comparison result

3. Final processing:
   - Apply correct sign to result based on input operands
   - Check for division by zero exception
