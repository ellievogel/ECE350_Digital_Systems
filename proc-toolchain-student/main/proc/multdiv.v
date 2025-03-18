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

    // wire [31:0] data_operandA_output, data_operandB_output;
    // register data_a_reg(
    //     .dataIn(data_operandA),
    //     .clk(clock),
    //     .writeEnable(ctrl_MULT | ctrl_DIV),
    //     .reset(1'b0),
    //     .dataOut(data_operandA_output)
    // );
    // register data_b_reg(
    //     .dataIn(data_operandB),
    //     .clk(clock),
    //     .writeEnable(ctrl_MULT | ctrl_DIV),
    //     .reset(1'b0),
    //     .dataOut(data_operandB_output)
    // );

    wire [31:0] mult_data_result;
    wire mult_data_exception, mult_data_resultRDY;
    wire [31:0] div_data_result;
    wire div_data_exception, div_data_resultRDY;
    wire mult, div;

    multiplier multiply(.data_operandA(data_operandA), .data_operandB(data_operandB), .ctrl_MULT(ctrl_MULT), .clock(clock), .data_result(mult_data_result), .data_exception(mult_data_exception), .data_resultRDY(mult_data_resultRDY));
    divider divide(.data_operandA(data_operandA), .data_operandB(data_operandB), .ctrl_DIV(ctrl_DIV), .clock(clock), .data_result(div_data_result), .data_exception(div_data_exception), .data_resultRDY(div_data_resultRDY));

    mux_2_parameter #(32) output_mux(
        .out(data_result), 
        .select(mult), 
        .in0(div_data_result), 
        .in1(mult_data_result)
    );

    mux_2_parameter #(1) exception_mux(
        .out(data_exception), 
        .select(mult), 
        .in0(div_data_exception), 
        .in1(mult_data_exception)
    );

    sl_latch mylatch(.R(ctrl_MULT), .S(ctrl_DIV), .Qa(div), .Qb(mult));

    mux_2_parameter #(1) ready_mux(
        .out(data_resultRDY), 
        .select(mult),
        .in0(div_data_resultRDY), 
        .in1(mult_data_resultRDY)
    );

endmodule