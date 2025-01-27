// Author: Ellie Vogel (eov2)

module one_bit_adder(S, Cout, A, B, Cin);

input A, B, Cin;
output S, Cout;
wire r_1, r_2, r_3, r_4, r_5, r_6, r_7;

nand nand_1(r_1, A, B);
nand nand_2(r_2, A, r_1);
nand nand_3(r_3, r_1, B);
nand nand_4(r_4, r_3, r_2);
nand nand_5(r_5, r_4, Cin);
nand nand_6(r_6, r_4, r_5);
nand nand_7(r_7, r_5, Cin);
nand nand_8(Cout, r_1, r_5);
nand nand_9(S, r_6, r_7);

endmodule