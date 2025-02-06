// Assignment Notes:
    // you should expect that the data_operand A and B signals will not remain constant. To avoid errors from changing operands, make sure that you latch the inputs when a mult or div operation has started
    // Use Booth's algorithm
    // Handles 32-bit integers and correctly asserts a data_exception on overflow
    // Correctly asserts the data_resultRDY signal when a correct result is produced
    // Correctly asserts a data_exception on a division by zero
    // If a current operation is underway, you should simply terminate the previous operation and restart
    // data_resultRDY should assert true for one cycle if and only if the module has completed an operation
        // The module must assert ready on a rising edge, and stay on for a full cycle. 
        // Even if there is a data_exception, this flag needs to be asserted
    // TO-DO: WRITE README
    // To pass this checkpoint, you will need to create your own csv files that test the multdiv edge cases

module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

    // data_operandA = multiplicand
    // data_operandB = multiplier

    wire[31:0] product;
    assign product = 32'b0;

    register #(65) product_and_multiplier_register(.clock(clock), .ctrl_writeEnable(1'b1), .ctrl_reset(), .ctrl_writeReg(), .ctrl_readRegA(), .ctrl_readRegB(), .data_writeReg(), .data_readRegA(), .data_readRegB());

    assign data_result = 32'b0;
    assign data_exception = 1'b0;
    assign data_resultRDY = 1'b1;





endmodule