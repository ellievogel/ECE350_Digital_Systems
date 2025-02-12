module multdiv(
    data_operandA, data_operandB, 
    ctrl_MULT, ctrl_DIV, 
    clock, 
    data_result, data_exception, data_resultRDY
);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;
    output [31:0] data_result;
    output data_exception, data_resultRDY;

    wire [31:0] mult_data_result;
    wire mult_data_exception, mult_data_resultRDY;
    // wire [31:0] div_data_result;
    // wire div_data_exception, div_data_resultRDY;

    multiplier multiply(.data_operandA(data_operandA), .data_operandB(data_operandB), .ctrl_MULT(ctrl_MULT), .clock(clock), .data_result(mult_data_result), .data_exception(mult_data_exception), .data_resultRDY(mult_data_resultRDY));
    // divider divide(.data_operandA(data_operandA), .data_operandB(data_operandB), .ctrl_DIV(ctrl_DIV), .clock(clock), .data_result(data_result), .data_exception(data_exception), .data_resultRDY(data_resultRDY));

    assign data_result = mult_data_result;
    assign data_exception = mult_data_exception;
    assign data_resultRDY = mult_data_resultRDY;

endmodule