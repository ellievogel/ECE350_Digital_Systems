// Author: Ellie Vogel (eov2)

module shift_right_multdiv(in, shiftamount, out);
    input [65:0] in;        // Changed input width to 66 bits
    input [4:0] shiftamount;
    output [65:0] out;      // Changed output width to 66 bits

    wire [65:0] shifted1, shifted2, shifted4, shifted8, shifted16;
    wire [65:0] out0, out1, out2, out3;

    assign shifted1 = {in[65], in[65:1]};   // Shift by 1 bit, extending the MSB
    mux_2_parameter #(66) mux1(.out(out0), .select(shiftamount[0]), .in0(in), .in1(shifted1));

    assign shifted2 = {{2{out0[65]}}, out0[65:2]}; // Shift by 2 bits, extending the MSB
    mux_2_parameter #(66) mux2(.out(out1), .select(shiftamount[1]), .in0(out0), .in1(shifted2));

    assign shifted4 = {{4{out1[65]}}, out1[65:4]}; // Shift by 4 bits, extending the MSB
    mux_2_parameter #(66) mux3(.out(out2), .select(shiftamount[2]), .in0(out1), .in1(shifted4));

    assign shifted8 = {{8{out2[65]}}, out2[65:8]}; // Shift by 8 bits, extending the MSB
    mux_2_parameter #(66) mux4(.out(out3), .select(shiftamount[3]), .in0(out2), .in1(shifted8));

    assign shifted16 = {{16{out3[65]}}, out3[65:16]}; // Shift by 16 bits, extending the MSB
    mux_2_parameter #(66) mux5(.out(out), .select(shiftamount[4]), .in0(out3), .in1(shifted16));

endmodule
