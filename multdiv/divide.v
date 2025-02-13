module divider(
    data_operandA, data_operandB, 
    ctrl_DIV,
    clock, 
    data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_DIV, clock;
    output [31:0] data_result;
    output data_exception, data_resultRDY;
    wire [4:0] count;

    wire add_back;
    assign start = ctrl_DIV;
    assign add_back = remainder_and_quotient_out[63];
    wire[63:0] remainder_and_quotient_in, remainder_and_quotient_out;

    counter64 iteration_counter(
        .clock(clock), 
        .reset(ctrl_MULT), 
        .count(count)
    );

    register #(64) remainder_and_quotient_register (
        .dataIn(remainder_and_quotient_in),
        .clk(clock),
        .writeEnable(1'b1),
        .reset(1'b0),
        .dataOut(remainder_and_quotient_out)
    );

    wire[31:0] correct_divisor;
    wire add_or_sub;
    mux_2 #(32) divisor_or_not(.out(correct_divisor), .select(add_back), .in0(data_operandB), .in1(~data_operandB));
    mux_2 #(1) addsub(.out(add_or_sub), .select(add_back), .in0(1'b0), .in1(1'b1));

    wire [31:0] adder_result;
    wire [63:0] shifted;
    wire adder_cout, adder_overflow;

    assign shifted = {remainder_and_quotient_out[62:0], 1'b0};

    cla add_sub(
        .S(adder_result), 
        .Cout(adder_cout), 
        .overflow(adder_overflow), 
        .A(shifted[63:32]), 
        .B(correct_divisor), 
        .Cin(add_or_sub)
    );

    wire [63:0] set_quotient_and_dividend;
    assign set_quotient_and_dividend[63:32] = 33'b0;
    assign set_quotient_and_dividend[31:0] = data_operandA;

    wire [63:0] combined;
    assign combined[63:32] = adder_result;
    assign combined[31:0] = remainder_and_quotient_out[31:0];

    wire[63:0] final_output;
    mux_2 #(64) initialization_mux(.out(final_output), .select(start), .in0(combined), .in1(set_quotient_and_dividend));
    assign remainder_and_quotient_in = final_output;
    assign data_result = remainder_and_quotient_out[31:0];

    assign data_exception = 1'b1;
    assign data_resultRDY = (count[5] & ~count[4] & ~count[3] & ~count[2] & ~count[1] & ~count[0]) ? 1'b1 : 1'b0;


endmodule;