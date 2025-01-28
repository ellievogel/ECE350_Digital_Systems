// Author: Ellie Vogel (eov2)

module or_32_bits(result, A, B);

    input [7:0] A, B;
    output [7:0] result;

    or or_gate0(result[0], A[0], B[0]);
    or or_gate1(result[1], A[1], B[1]);
    or or_gate2(result[2], A[2], B[2]);
    or or_gate3(result[3], A[3], B[3]);
    or or_gate4(result[4], A[4], B[4]);
    or or_gate5(result[5], A[5], B[5]);
    or or_gate6(result[6], A[6], B[6]);
    or or_gate7(result[7], A[7], B[7]);
    // or or_gate8(result[8], A[8], B[8]);
    // or or_gate9(result[9], A[9], B[9]);
    // or or_gate10(result[10], A[10], B[10]);
    // or or_gate11(result[11], A[11], B[11]);
    // or or_gate12(result[12], A[12], B[12]);
    // or or_gate13(result[13], A[13], B[13]);
    // or or_gate14(result[14], A[14], B[14]);
    // or or_gate15(result[15], A[15], B[15]);
    // or or_gate16(result[16], A[16], B[16]);
    // or or_gate17(result[17], A[17], B[17]);
    // or or_gate18(result[18], A[18], B[18]);
    // or or_gate19(result[19], A[19], B[19]);
    // or or_gate20(result[20], A[20], B[20]);
    // or or_gate21(result[21], A[21], B[21]);
    // or or_gate22(result[22], A[22], B[22]);
    // or or_gate23(result[23], A[23], B[23]);
    // or or_gate24(result[24], A[24], B[24]);
    // or or_gate25(result[25], A[25], B[25]);
    // or or_gate26(result[26], A[26], B[26]);
    // or or_gate27(result[27], A[27], B[27]);
    // or or_gate28(result[28], A[28], B[28]);
    // or or_gate29(result[29], A[29], B[29]);
    // or or_gate30(result[30], A[30], B[30]);
    // or or_gate31(result[31], A[31], B[31]);

endmodule