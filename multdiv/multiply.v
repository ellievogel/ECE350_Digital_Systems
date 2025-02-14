module multiplier(
    data_operandA, data_operandB, 
    ctrl_MULT,
    clock, 
    data_result, data_exception, data_resultRDY
);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, clock;
    output [31:0] data_result;
    output data_exception, data_resultRDY;

    wire [31:0] multiplier;
    wire start, shift, nothing;
    wire [5:0] count;

    wire [65:0] product_and_multiplier_in, product_and_multiplier_out;

    assign start = ctrl_MULT;
    assign shift = (product_and_multiplier_out[2] & !product_and_multiplier_out[1] & !product_and_multiplier_out[0]) || (!product_and_multiplier_out[2] & product_and_multiplier_out[1] & product_and_multiplier_out[0]) ? 1: 0;
    assign nothing = (!product_and_multiplier_out[2] & !product_and_multiplier_out[1] & !product_and_multiplier_out[0]) || (product_and_multiplier_out[2] & product_and_multiplier_out[1] & product_and_multiplier_out[0]);
    assign subtract = (product_and_multiplier_out[2] & !product_and_multiplier_out[1] & !product_and_multiplier_out[0]) || (product_and_multiplier_out[2] & product_and_multiplier_out[1] & !product_and_multiplier_out[0]) || (product_and_multiplier_out[2] & !product_and_multiplier_out[1] & product_and_multiplier_out[0]);

    counter64 iteration_counter(
        .clock(clock), 
        .reset(ctrl_MULT), 
        .count(count)
    );

    register #(32) multiplier_register (
        .dataIn(data_operandB),
        .clk(clock),
        .writeEnable(ctrl_MULT),
        .reset(ctrl_MULT),
        .dataOut(multiplier)
    );

    register #(66) product_and_multiplier_register (
        .dataIn(product_and_multiplier_in),
        .clk(clock),
        .writeEnable(1'b1),
        .reset(1'b0),
        .dataOut(product_and_multiplier_out)
    );

    wire [31:0] shifted;
    shift_left left(.in(data_operandA), .shiftamount(5'd1), .out(shifted));
    wire [31:0] shifted_output;
    mux_2 #(32) shift_mux(.out(shifted_output), .select(shift), .in0(data_operandA), .in1(shifted));

    wire [31:0] adder_result, subtractor_result;
    wire adder_cout, adder_overflow, subtractor_cout, subtractor_overflow;

    cla adder(
        .S(adder_result), 
        .Cout(adder_cout), 
        .overflow(adder_overflow), 
        .A(product_and_multiplier_out[64:33]), 
        .B(shifted_output), 
        .Cin(1'b0)
    );

    cla subtractor(
        .S(subtractor_result), 
        .Cout(subtractor_cout), 
        .overflow(subtractor_overflow), 
        .A(product_and_multiplier_out[64:33]), 
        .B(~shifted_output), 
        .Cin(1'b1) 
    );

    wire [31:0] intermediate_mux_output;
    mux_2 #(32) first_mux(
        .out(intermediate_mux_output), 
        .select(subtract), 
        .in0(adder_result), 
        .in1(subtractor_result)
    );

    wire [31:0] operation_output;
    mux_2 #(32) second_mux(
        .out(operation_output), 
        .select(nothing), 
        .in0(intermediate_mux_output), 
        .in1(product_and_multiplier_out[64:33])
    );

    wire [65:0] combined;
    assign combined[65] = combined[64];
    // assign combined[64] = combined[63];
    assign combined[64:33] = operation_output;
    assign combined[32:0] = product_and_multiplier_out[32:0];

    wire [65:0] shift_right;
    shift_right rightshifter(.in(combined), .shiftamount(5'd2), .out(shift_right));

    wire [65:0] final_output;
    wire [65:0] set_input_b;
    assign set_input_b[65:33] = 33'b0;
    assign set_input_b[32:1] = data_operandB;
    assign set_input_b[0] = 1'b0;

    mux_2 #(66) shift_right_mux(.out(final_output), .select(start), .in0(shift_right), .in1(set_input_b));

    assign product_and_multiplier_in = final_output;

    assign data_result = product_and_multiplier_out[32:1];
    wire [33:0] top;
    assign top = product_and_multiplier_out[65:32];

    wire sign_exception;
    assign sign_exception = (data_operandA[31] & data_operandB[31] & data_result[31]) || (!data_operandA[31] & !data_operandB[31] & data_result[31]);
    assign data_exception = (product_and_multiplier_out[64] & (!(&product_and_multiplier_out[63:32]))) || (!product_and_multiplier_out[64] & (|product_and_multiplier_out[63:32])) || sign_exception;
    assign data_resultRDY = (~count[5] & count[4] & ~count[3] & ~count[2] & ~count[1] & ~count[0]) ? 1'b1 : 1'b0;


endmodule