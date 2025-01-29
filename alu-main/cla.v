// Author: Ellie Vogel (eov2)

module cla(S, Cout, overflow, A, B, Cin);

input [31:0] A, B;
input Cin;
output [31:0] S;
output Cout;
output overflow;

wire [31:0] gs, ps;
wire[3:0] big_G, big_P;
wire Cin_8, Cin_16, Cin_24;
wire big_P_0, big_G_0, big_P_1, big_G_1, big_P_2, big_G_2, big_P_3, big_G_3;

and_32_bits create_gs(.result(gs), .A(A), .B(B));
or_32_bits create_ps(.result(ps), .A(A), .B(B));

wire p0c0, p1g0, p1p0c0, p2g1, p2p1g0, p2p1p0cin;

cla_block cla_block_0_7(.S(S[7:0]), .Cin(Cin), .big_P(big_P_0), .big_G(big_G_0), .A(A[7:0]), .B(B[7:0]), .Gs(gs[7:0]), .Ps(ps[7:0]));
and and_gate(p0c0, big_P_0, Cin);
or c_8(Cin_8, big_G_0, p0c0);

cla_block cla_block_8_15(.S(S[15:8]), .Cin(Cin_8), .big_P(big_P_1), .big_G(big_G_1), .A(A[15:8]), .B(B[15:8]), .Gs(gs[15:8]), .Ps(ps[15:8]));
and p1_g0(p1g0, big_P_1, big_G_0);
and p1_p0_c0(p1p0c0, big_P_1, big_P_0, Cin);
or c_16(Cin_16, p1g0, p1p0c0, big_G_1);

cla_block cla_block_16_23(.S(S[23:16]), .Cin(Cin_16), .big_P(big_P_2), .big_G(big_G_2), .A(A[23:16]), .B(B[23:16]), .Gs(gs[23:16]), .Ps(ps[23:16]));
and p2_g1(p2g1, big_P_2, big_G_1);
and p2_p1_g0(p2p1g0, big_P_2, big_P_1, big_G_0);
and p2_p1_p0_cin(p2p1p0cin, big_P_2, big_P_1, big_P_0, Cin);
or c_24(Cin_24, big_G_2, p2g1, p2p1g0, p2p1p0cin);

wire p3g2, p3p2g1, p3p2p1g0, p3p2p1p0cin;

cla_block cla_block_24_31(.S(S[31:24]), .Cin(Cin_24), .big_P(big_P_3), .big_G(big_G_3), .A(A[31:24]), .B(B[31:24]), .Gs(gs[31:24]), .Ps(ps[31:24]));
and p3_g2(p3g2, big_P_3, big_G_2);
and p3_p2_g1(p3p2g1, big_P_3, big_P_2, big_G_1);
and p3_p2_p1_g0(p3p2p1g0, big_P_3, big_P_2, big_P_1, big_G_0);
and p3_p2_p1_p0_cin(p3p2p1p0cin, big_P_3, big_P_2, big_P_1, big_P_0, Cin);
or c_out(Cout, big_G_3, p3g2, p3p2g1, p3p2p1g0, p3p2p1p0cin);

wire xor_a_b, xor_sum_a;

xor xor_gate1(xor_a_b, A[31], B[31]);
xor xor_gate2(xor_sum_a, S[31], A[31]);
assign overflow = xor_a_b ? 1'b0 : xor_sum_a;

endmodule