// Author: Ellie Vogel (eov2)

module alu(
    data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt,
    data_result, isNotEqual, isLessThan, overflow
);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
    wire add_overflow, sub_overflow;

    output [31:0] data_result;
    output isNotEqual, isLessThan, add_overflow, sub_overflow;
    
    wire [31:0] S, sub, and_result, or_result, shift_left_result, shift_right_result;
    wire Cin, Cout, dummy, dummy2;

    cla cla_unit(.S(S), .Cout(dummy), .overflow(add_overflow), .A(data_operandA), .B(data_operandB), .Cin(1'b0));
    subtract sub_unit(.S(sub), .Cout(dummy2), .overflow(sub_overflow), .A(data_operandA), .B(data_operandB));
    shift_left left_shifter(.in(data_operandA), .shiftamount(ctrl_shiftamt), .out(shift_left_result));
    shift_right right_shifter(.in(data_operandA), .shiftamount(ctrl_shiftamt), .out(shift_right_result));
    and_32_bits and_operation(.result(and_result), .A(data_operandA), .B(data_operandB));
    or_32_bits or_operation(.result(or_result), .A(data_operandA), .B(data_operandB));

    mux_8 selector_mux(
        .out(data_result),
        .select(ctrl_ALUopcode[2:0]),
        .in0(S), .in1(sub), .in2(and_result), .in3(or_result),
        .in4(shift_left_result), .in5(shift_right_result),
        .in6(data_operandA), .in7(data_operandB)
    );

    output overflow;

    assign overflow = ctrl_ALUopcode[0] ? sub_overflow : add_overflow;

    xor xor_gate_LT(isLessThan, sub[31], overflow);
    or or_gate(isNotEqual, sub[31], sub[30], sub[29], sub[28], sub[27], sub[26], sub[25], sub[24], sub[23], sub[22], sub[21], sub[20], sub[19], sub[18], sub[17], sub[16], sub[15], sub[14], sub[13], sub[12], sub[11], sub[10], sub[9], sub[8], sub[7], sub[6], sub[5], sub[4], sub[3], sub[2], sub[1], sub[0]);

endmodule