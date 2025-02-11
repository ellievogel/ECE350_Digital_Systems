// TO-DO: WRITE README

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

    wire [31:0] multiplicand, multiplier;
    wire start, shift, nothing;
    wire [4:0] count;

    wire [65:0] product_and_multiplier_in, product_and_multiplier_out;
    wire [2:0] lsbs_start = {data_operandB[1:0],1'b0};

    wire [2:0] lsbs;
    assign lsbs = (count == 5'b0) ? lsbs_start : product_and_multiplier_out[2:0];
    assign start = ctrl_MULT;
    assign shift = (lsbs[2] & !lsbs[1] & !lsbs[0]) || (!lsbs[2] & lsbs[1] & lsbs[0]) ? 1: 0;
    assign nothing = (!lsbs[2] & !lsbs[1] & !lsbs[0]) || (lsbs[2] & lsbs[1] & lsbs[0]);
    assign subtract = (lsbs[2] & !lsbs[1] & !lsbs[0]) || (lsbs[2] & lsbs[1] & !lsbs[0]) || (lsbs[2] & !lsbs[1] & lsbs[0]);

    counter64 iteration_counter(
        .clock(clock), 
        .reset(ctrl_MULT), 
        .count(count)
    );

    register #(32) multiplicand_register (
        .dataIn(data_operandA),
        .clk(clock),
        .writeEnable(ctrl_MULT),
        .reset(ctrl_MULT),
        .dataOut(multiplicand)
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
    shift_left left(.in(multiplicand), .shiftamount(5'd1), .out(shifted));
    wire [31:0] shifted_output;
    mux_2 #(32) shift_mux(.out(shifted_output), .select(shift), .in0(multiplicand), .in1(shifted));

    wire[31:0] shifted_corrected;
    assign shifted_corrected = (count == 5'b0) ? data_operandB : shifted_output;

    wire [31:0] adder_result, subtractor_result;
    wire adder_cout, adder_overflow, subtractor_cout, subtractor_overflow;

    cla adder(
        .S(adder_result), 
        .Cout(adder_cout), 
        .overflow(adder_overflow), 
        .A(shifted_corrected), 
        .B(shifted_output), 
        .Cin(1'b0)
    );

    cla subtractor(
        .S(subtractor_result), 
        .Cout(subtractor_cout), 
        .overflow(subtractor_overflow), 
        .A(32'b0), 
        .B(~shifted_corrected), 
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
        .in1(product_and_multiplier_out[63:32])
    );

    wire [65:0] combined;
    assign combined[65] = combined[64];
    assign combined[64] = combined[63];
    assign combined[63:32] = operation_output;
    assign combined[31:0] = product_and_multiplier_out[31:0];

    wire [65:0] shift_right;
    shift_right rightshifter(.in(combined), .shiftamount(5'd2), .out(shift_right));

    wire [65:0] final_output;
    wire [65:0] set_input_b;
    assign set_input_b[65:32] = 32'b0;
    assign set_input_b[31:0] = data_operandB;

    mux_2 #(66) shift_right_mux(.out(final_output), .select(start), .in0(shift_right), .in1(set_input_b));

    assign product_and_multiplier_in = final_output;

    assign data_result = product_and_multiplier_out[31:0];
    assign data_exception = (product_and_multiplier_out[65:32] != 0 && product_and_multiplier_out[65:32] != ~0);
    assign data_resultRDY = (count == 6'd31);

endmodule