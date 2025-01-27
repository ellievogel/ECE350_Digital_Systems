// Author: Ellie Vogel (eov2)

module cla(S, Cout, A, B, Cin);

wire [31:0] gs, ps;
and_32 create_gs(.gs(gs), .A(A), .B(B));
or_32 create_ps(.ps(ps), .A(A), .B(B));

wire Cin_8, Cin_16, Cin_24

// Cin_8
// Cin8big_P0 + big_G0

cla_block cla_block_0_7(.S(S[7:0]), .Cin(Cin), .big_P(big_P), .big_G(big_G), .A(A[7:0]), .B(B[7:0]), .Gs(gs[7:0], .Ps(ps[7:0]));
cla_block cla_block_8_15(.S(S[15:8]), .Cin(Cin), .big_P(big_P), .big_G(big_G), .A(A[15:8]), .B(B[15:8]), .Gs(gs[15:8]), .Ps(ps[15:8]));



// To-Do: Use and gate to make Gs and Ps
// To-Do: Make big_ps and big_gs

endmodule

// big_p = P7P6P5P4P3P2P1P0
//