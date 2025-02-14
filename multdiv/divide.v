module divider(
    data_operandA, data_operandB, 
    ctrl_DIV,
    clock, 
    data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_DIV, clock;
    output [31:0] data_result;
    output data_exception, data_resultRDY;
    
    wire [5:0] count;
    wire [31:0] int_result;
    
    wire add_back;
    assign add_back = remainder_and_quotient_out[63];
    
    wire [63:0] remainder_and_quotient_in, remainder_and_quotient_out;
    
    counter64 iteration_counter(
        .clock(clock), 
        .reset(ctrl_DIV), 
        .count(count)
    );

    wire [31:0] abs_operandA, abs_operandB;
    assign abs_operandA = data_operandA[31] ? (~data_operandA + 1'b1) : data_operandA;
    assign abs_operandB = data_operandB[31] ? (~data_operandB + 1'b1) : data_operandB;

    register #(64) remainder_and_quotient_register (
        .dataIn(remainder_and_quotient_in),
        .clk(clock),
        .writeEnable(1'b1),
        .reset(1'b0),
        .dataOut(remainder_and_quotient_out)
    );

    wire [31:0] correct_divisor;
    wire add_or_sub;
    mux_2 #(32) divisor_or_not(
        .out(correct_divisor), 
        .select(add_back), 
        .in0(~abs_operandB + 1'b1),
        .in1(abs_operandB)
    );
    
    mux_2 #(1) addsub(
        .out(add_or_sub), 
        .select(add_back), 
        .in0(1'b0), 
        .in1(1'b0)
    );

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
    assign set_quotient_and_dividend = {32'b0, abs_operandA};

    wire [63:0] combined;
    assign combined[63:32] = adder_result;
    assign combined[31:0] = {remainder_and_quotient_out[30:0], ~add_back};

    wire [63:0] final_output;
    mux_2 #(64) initialization_mux(
        .out(final_output), 
        .select(ctrl_DIV), 
        .in0(combined), 
        .in1(set_quotient_and_dividend)
    );
    
    assign remainder_and_quotient_in = final_output;
    assign int_result = remainder_and_quotient_out[31:0];

    wire result_negate;
    assign result_negate = data_operandA[31] ^ data_operandB[31];

    wire [31:0] final_result;
    assign final_result = result_negate ? (~int_result + 1'b1) : int_result;
    assign data_result = final_result;

    wire operandB_is_zero;
    assign operandB_is_zero = ~(|data_operandB);
    assign data_exception = operandB_is_zero;
    assign data_resultRDY = (count[5] & ~count[4] & ~count[3] & ~count[2] & ~count[1] & count[0]) ? 1'b1 : 1'b0;

endmodule