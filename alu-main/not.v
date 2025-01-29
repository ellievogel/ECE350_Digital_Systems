// Author: Ellie Vogel (eov2)

module not_32_bits(result, B);

    input [31:0] B;
    output [31:0] result;

    not not0(result[0], B[0]);
    not not1(result[1], B[1]);
    not not2(result[2], B[2]);
    not not3(result[3], B[3]);
    not not4(result[4], B[4]);
    not not5(result[5], B[5]);
    not not6(result[6], B[6]);
    not not7(result[7], B[7]);
    not not8(result[8], B[8]);
    not not9(result[9], B[9]);
    not not10(result[10], B[10]);
    not not11(result[11], B[11]);
    not not12(result[12], B[12]);
    not not13(result[13], B[13]);
    not not14(result[14], B[14]);
    not not15(result[15], B[15]);
    not not16(result[16], B[16]);
    not not17(result[17], B[17]);
    not not18(result[18], B[18]);
    not not19(result[19], B[19]);
    not not20(result[20], B[20]);
    not not21(result[21], B[21]);
    not not22(result[22], B[22]);
    not not23(result[23], B[23]);
    not not24(result[24], B[24]);
    not not25(result[25], B[25]);
    not not26(result[26], B[26]);
    not not27(result[27], B[27]);
    not not28(result[28], B[28]);
    not not29(result[29], B[29]);
    not not30(result[30], B[30]);
    not not31(result[31], B[31]);

endmodule