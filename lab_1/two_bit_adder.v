// Author: Ellie Vogel (eov2)

module two_bit_adder(S0, S1, Cout, A0, A1, B0, B1, Cin);

input A0, A1, B0, B1, Cin;
output S0, S1, Cout;
wire Cout_one;

full_adder adder_zero(S0, Cout_one, A0, B0, Cin);
full_adder adder_one(S1, Cout, A1, B1, Cout_one);

endmodule