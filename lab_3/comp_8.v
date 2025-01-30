module comp_8(EQ1, GT1, A, B, EQ0, GT0);
    input EQ1, GT1;
    input [7:0] A, B;
    output EQ0, GT0;

    wire EQ0_2, GT0_2, EQ1_2, GT1_2;
    wire EQ2_2, GT2_2, EQ3_2, GT3_2;

    comp_2 comp_0(
        .EQ1(EQ1), .GT1(GT1), .A(A[1:0]), .B(B[1:0]), 
        .EQ0(EQ0_2), .GT0(GT0_2)
    );
    comp_2 comp_1(
        .EQ1(EQ0_2), .GT1(GT0_2), .A(A[3:2]), .B(B[3:2]), 
        .EQ0(EQ1_2), .GT0(GT1_2)
    );
    comp_2 comp_2(
        .EQ1(EQ1_2), .GT1(GT1_2), .A(A[5:4]), .B(B[5:4]), 
        .EQ0(EQ2_2), .GT0(GT2_2)
    );
    comp_2 comp_3(
        .EQ1(EQ2_2), .GT1(GT2_2), .A(A[7:6]), .B(B[7:6]), 
        .EQ0(EQ0), .GT0(GT0)
    );

endmodule
