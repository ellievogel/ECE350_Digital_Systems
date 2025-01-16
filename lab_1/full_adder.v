// Author: Ellie Vogel (eov2)

module full_adder(S, Cout, A, B, Cin);

input A, B, Cin;
output S, Cout;
wire and1, and2, and3;

xor xor_gate(S, A, B, Cin);

and and1_gate(and1, A, B);
and and2_gate(and2, A, Cin);
and and3_gate(and3, B, Cin);

or or_gate(Cout, and1, and2, and3);

endmodule