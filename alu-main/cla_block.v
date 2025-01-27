// Author: Ellie Vogel (eov2)

module cla_block(S, Cout, big_P, big_G, Cin, A, B, Gs, Ps);

input [7:0] A, B, Gs, Ps;
input Cin;
output [7:0] S;
output Cout;
wire cin_1, cin_2, cin_3, cin_4, cin_5, cin_6, cin_7;
wire P0_C0;

// Cin_1
// CinP0 + G0
and(P0_C0, Ps[0], Cin)
or(cin_1, P0_C0, Gs[0])

// Cin_2
// G1 + G0P1 + CinP0P1
and(P1_C1, Ps[1], Cin_1)
or(cin_2, P1_C1, Gs[1])

// Cin_3
// G2 + G1P2 + G0P1P2 + CinP0P1P2


// Cin_4
// G3 + G2P3 + G1P2P3 + G0P1P2P3 + CinP0P1P2P3


// Cin_5
// G4 + G3P4 + G2P3P4 + G1P2P3P4 + G0P1P2P3P4 + CinP0P1P2P3P4


// Cin_6
// G5 + G4P5 + G3P4P5 + G2P3P4P5 + G1P2P3P4P5 + G0P1P2P3P4P5 + CinP0P1P2P3P4P5


// Cin_6
// G5 + G4P5 + G3P4P5 + G2P3P4P5 + G1P2P3P4P5 + G0P1P2P3P4P5 + CinP0P1P2P3P4P5


// Cin_7
// G6 + G5P6 + G4P5P6 + G3P4P5P6 + G2P3P4P5P6 + G1P2P3P4P5P6 + G0P1P2P3P4P5P6 + CinP0P1P2P3P4P5P6


// Cout
// G7 + G6P7 + G5P6P7 + G4P5P6P7 + G3P4P5P6P7 + G2P3P4P5P6P7 + G1P2P3P4P5P6P7 + G0P1P2P3P4P5P6P7 + CinP0P1P2P3P4P5P6P7


// To-Do: Fix these numbers
xor xor_gate_0(S[0], A[0], B[0], Cin);
xor xor_gate_1(S[1], A[1], B[1], Cin_1);
xor xor_gate_2(S[2], A[2], B[2], Cin_2);
xor xor_gate_3(S[1], A[1], B[1], Cin_3);
xor xor_gate_4(S[1], A[1], B[1], Cin_4);
xor xor_gate_5(S[1], A[1], B[1], Cin_5);
xor xor_gate_6(S[1], A[1], B[1], Cin_6);
xor xor_gate_7(S[1], A[1], B[1], Cin_7);


endmodule