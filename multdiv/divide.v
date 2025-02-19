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

    // Absolute value calculation for operand A
    wire [31:0] abs_operandA, abs_operandA_neg;
    wire [31:0] negatea;
    wire negatea_cout, negatea_overflow;
    
    assign negatea = ~data_operandA;
    cla negate_A(
        .S(abs_operandA_neg),
        .Cout(negatea_cout),
        .overflow(negatea_overflow),
        .A(negatea),
        .B(32'b1),
        .Cin(1'b0)
    );
    assign abs_operandA = data_operandA[31] ? abs_operandA_neg : data_operandA;

    // Absolute value calculation for operand B
    wire [31:0] abs_operandB, abs_operandB_neg;
    wire [31:0] negateb;
    wire negateb_cout, negateb_overflow;
    
    assign negateb = ~data_operandB;
    cla negate_B(
        .S(abs_operandB_neg),
        .Cout(negateb_cout),
        .overflow(negateb_overflow),
        .A(negateb),
        .B(32'b1),
        .Cin(1'b0)
    );
    assign abs_operandB = data_operandB[31] ? abs_operandB_neg : data_operandB;

    // Negation of abs_operandB for the divisor
    wire [31:0] neg_abs_operandB;
    wire [31:0] neg_abs_operandB_result;
    wire neg_abs_operandB_cout, neg_abs_operandB_overflow;
    
    assign neg_abs_operandB = ~abs_operandB;
    cla negate_abs_B(
        .S(neg_abs_operandB_result),
        .Cout(neg_abs_operandB_cout),
        .overflow(neg_abs_operandB_overflow),
        .A(neg_abs_operandB),
        .B(32'b1),
        .Cin(1'b0)
    );

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
        .in0(neg_abs_operandB_result),  // Changed to use CLA result
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
    
    // Final result negation using CLA
    wire [31:0] neg_result, final_result;
    wire neg_result_cout, neg_result_overflow;
    
    assign neg_result = ~int_result;
    cla negate_result(
        .S(final_result),
        .Cout(neg_result_cout),
        .overflow(neg_result_overflow),
        .A(neg_result),
        .B(32'b1),
        .Cin(1'b0)
    );
    
    assign data_result = result_negate ? final_result : int_result;
    
    wire operandB_is_zero;
    assign operandB_is_zero = ~(|data_operandB);
    assign data_exception = operandB_is_zero;
    assign data_resultRDY = (count[5] & ~count[4] & ~count[3] & ~count[2] & ~count[1] & count[0]) ? 1'b1 : 1'b0;

endmodule