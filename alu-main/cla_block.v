// Author: Ellie Vogel (eov2)

module cla_block(S, Cout, Cin, A, B, Gs, Ps);

input [7:0] A, B, Gs, Ps;
input Cin;
output [7:0] S;
output Cout;
wire cin_1, cin_2, cin_3, cin_4, cin_5, cin_6, cin_7;
wire P0_C0, P1_C1, G1_P2, G0_P1_P2, Cin_P0_P1_P2;

// Additional wires for larger carries
wire G3_P4, G2_P3P4, G1_P2P3P4, G0_P1P2P3P4, Cin_P0P1P2P3P4;
wire G4_P5, G3_P4P5, G2_P3P4P5, G1_P2P3P4P5, G0_P1P2P3P4P5, Cin_P0P1P2P3P4P5;
wire G5_P6, G4_P5P6, G3_P4P5P6, G2_P3P4P5P6, G1_P2P3P4P5P6, G0_P1P2P3P4P5P6, Cin_P0P1P2P3P4P5P6;
wire G6_P7, G5_P6P7, G4_P5P6P7, G3_P4P5P6P7, G2_P3P4P5P6P7, G1_P2P3P4P5P6P7, G0_P1P2P3P4P5P6P7, Cin_P0P1P2P3P4P5P6P7;

// Cin_1
// CinP0 + G0
and(P0_C0, Ps[0], Cin);
or(cin_1, P0_C0, Gs[0]);

// Cin_2
// G1 + G0P1 + CinP0P1
and(P1_C1, Ps[1], cin_1);
or(cin_2, P1_C1, Gs[1]);

// Cin_3
// G2 + G1P2 + G0P1P2 + CinP0P1P2
and(G1_P2, Gs[1], Ps[2]);
and(G0_P1_P2, Gs[0], Ps[1], Ps[2]);
and(Cin_P0_P1_P2, Cin, Ps[0], Ps[1], Ps[2]);
or(cin_3, Gs[2], G1_P2, G0_P1_P2, Cin_P0_P1_P2);

// Cin_4
// G3 + G2P3 + G1P2P3 + G0P1P2P3 + CinP0P1P2P3
and(G3_P4, Gs[3], Ps[4]);
and(G2_P3P4, Gs[2], Ps[3], Ps[4]);
and(G1_P2P3P4, Gs[1], Ps[2], Ps[3], Ps[4]);
and(G0_P1P2P3P4, Gs[0], Ps[1], Ps[2], Ps[3], Ps[4]);
and(Cin_P0P1P2P3P4, Cin, Ps[0], Ps[1], Ps[2], Ps[3], Ps[4]);
or(cin_4, Gs[3], G2_P3P4, G1_P2P3P4, G0_P1P2P3P4, Cin_P0P1P2P3P4);

// Cin_5
// G4 + G3P4 + G2P3P4 + G1P2P3P4 + G0P1P2P3P4 + CinP0P1P2P3P4
and(G4_P5, Gs[4], Ps[5]);
and(G3_P4P5, Gs[3], Ps[4], Ps[5]);
and(G2_P3P4P5, Gs[2], Ps[3], Ps[4], Ps[5]);
and(G1_P2P3P4P5, Gs[1], Ps[2], Ps[3], Ps[4], Ps[5]);
and(G0_P1P2P3P4P5, Gs[0], Ps[1], Ps[2], Ps[3], Ps[4], Ps[5]);
and(Cin_P0P1P2P3P4P5, Cin, Ps[0], Ps[1], Ps[2], Ps[3], Ps[4], Ps[5]);
or(cin_5, Gs[4], G3_P4P5, G2_P3P4P5, G1_P2P3P4P5, G0_P1P2P3P4P5, Cin_P0P1P2P3P4P5);

// Cin_6
// G5 + G4P5 + G3P4P5 + G2P3P4P5 + G1P2P3P4P5 + G0P1P2P3P4P5 + CinP0P1P2P3P4P5
and(G5_P6, Gs[5], Ps[6]);
and(G4_P5P6, Gs[4], Ps[5], Ps[6]);
and(G3_P4P5P6, Gs[3], Ps[4], Ps[5], Ps[6]);
and(G2_P3P4P5P6, Gs[2], Ps[3], Ps[4], Ps[5], Ps[6]);
and(G1_P2P3P4P5P6, Gs[1], Ps[2], Ps[3], Ps[4], Ps[5], Ps[6]);
and(G0_P1P2P3P4P5P6, Gs[0], Ps[1], Ps[2], Ps[3], Ps[4], Ps[5], Ps[6]);
and(Cin_P0P1P2P3P4P5P6, Cin, Ps[0], Ps[1], Ps[2], Ps[3], Ps[4], Ps[5], Ps[6]);
or(cin_6, Gs[5], G4_P5P6, G3_P4P5P6, G2_P3P4P5P6, G1_P2P3P4P5P6, G0_P1P2P3P4P5P6, Cin_P0P1P2P3P4P5P6);

// Cin_7
// G6 + G5P6 + G4P5P6 + G3P4P5P6 + G2P3P4P5P6 + G1P2P3P4P5P6 + G0P1P2P3P4P5P6 + CinP0P1P2P3P4P5P6
and(G6_P7, Gs[6], Ps[7]);
and(G5_P6P7, Gs[5], Ps[6], Ps[7]);
and(G4_P5P6P7, Gs[4], Ps[5], Ps[6], Ps[7]);
and(G3_P4P5P6P7, Gs[3], Ps[4], Ps[5], Ps[6], Ps[7]);
and(G2_P3P4P5P6P7, Gs[2], Ps[3], Ps[4], Ps[5], Ps[6], Ps[7]);
and(G1_P2P3P4P5P6P7, Gs[1], Ps[2], Ps[3], Ps[4], Ps[5], Ps[6], Ps[7]);
and(G0_P1P2P3P4P5P6P7, Gs[0], Ps[1], Ps[2], Ps[3], Ps[4], Ps[5], Ps[6], Ps[7]);
and(Cin_P0P1P2P3P4P5P6P7, Cin, Ps[0], Ps[1], Ps[2], Ps[3], Ps[4], Ps[5], Ps[6], Ps[7]);
or(cin_7, Gs[6], G5_P6P7, G4_P5P6P7, G3_P4P5P6P7, G2_P3P4P5P6P7, G1_P2P3P4P5P6P7, G0_P1P2P3P4P5P6P7, Cin_P0P1P2P3P4P5P6P7);

// Cout
// G7 + G6P7 + G5P6P7 + G4P5P6P7 + G3P4P5P6P7 + G2P3P4P5P6P7 + G1P2P3P4P5P6P7 + G0P1P2P3P4P5P6P7 + CinP0P1P2P3P4P5P6P7
or(Cout, Gs[7], G6_P7, G5_P6P7, G4_P5P6P7, G3_P4P5P6P7, G2_P3P4P5P6P7, G1_P2P3P4P5P6P7, G0_P1P2P3P4P5P6P7, Cin_P0P1P2P3P4P5P6P7);

// Fixed XOR gates for sum computation
xor xor_gate_0(S[0], A[0], B[0], Cin);
xor xor_gate_1(S[1], A[1], B[1], cin_1);
xor xor_gate_2(S[2], A[2], B[2], cin_2);
xor xor_gate_3(S[3], A[3], B[3], cin_3);
xor xor_gate_4(S[4], A[4], B[4], cin_4);
xor xor_gate_5(S[5], A[5], B[5], cin_5);
xor xor_gate_6(S[6], A[6], B[6], cin_6);
xor xor_gate_7(S[7], A[7], B[7], cin_7);

endmodule