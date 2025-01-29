// Author: Ellie Vogel (eov2)

module subtract(S, Cout, overflow, NE, A, B);
    wire [31:0] inverted_b;
    input [31:0] A, B;
    output [31:0] S;
    output Cout, NE;
    wire Cin;

    assign Cin = 1'b1;
    output overflow;

    not_32_bits not_b(.result(inverted_b), .B(B));
    cla cla_unit(.S(S), .Cout(Cout), .overflow(overflow), .A(A), .B(inverted_b), .Cin(Cin));

endmodule