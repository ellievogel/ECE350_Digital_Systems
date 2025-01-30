module comp_2(EQ1, GT1, A, B, EQ0, GT0);
    input EQ1, GT1;
    input [1:0] A, B;
    output EQ0, GT0;

    wire [2:0] select;
    wire eq_out;
    wire gt_out;
    
    assign select[0] = B[1];
    assign select[1] = A[1];
    assign select[2] = A[0];

    wire inverted_b_0;
    wire inverted_gt;
    wire inverted_eq;
    not (inverted_eq, EQ1);
    not(inverted_b_0, B[0]);
    not(inverted_gt, GT1);

    wire in0, in1, in2, in3, in4, in5, in6, in7;

    assign in0 = inverted_b_0;
    assign in1 = 1'b0;
    assign in2 = 1'b0;
    assign in3 = inverted_b_0;
    assign in4 = B[0];
    assign in5 = 1'b0;
    assign in6 = 1'b0;
    assign in7 = B[0];

    wire mux_out;

    mux_8 mux_one(.out(mux_out), .select(select), .in0(in0), .in1(in1), .in2(in2), .in3(in3), 
                  .in4(in4), .in5(in5), .in6(in6), .in7(in7));

    wire in0b, in1b, in2b, in3b, in4b, in5b, in6b, in7b;

    assign in0b = 1'b0;
    assign in1b = 1'b0;
    assign in2b = 1'b1;
    assign in3b = 1'b0;
    assign in4b = inverted_b_0;
    assign in5b = 1'b0;
    assign in6b = 1'b1;
    assign in7b = inverted_b_0;

    wire mux_out_b;

    mux_8 mux_two(.out(mux_out_b), .select(select), .in0(in0b), .in1(in1b), .in2(in2b), .in3(in3b), 
                  .in4(in4b), .in5(in5b), .in6(in6b), .in7(in7b));

    assign eq_out = mux_out;
    assign gt_out = mux_out_b;
    
    wire not_eq_gt, final_and;
    and (not_eq_gt, inverted_eq, GT1);
    and (final_and, EQ1, inverted_gt, gt_out);

    and(EQ0, EQ1, inverted_gt, eq_out);
    or(GT0, final_and, not_eq_gt);

endmodule
