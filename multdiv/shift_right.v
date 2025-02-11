// Author: Ellie Vogel (eov2)

module shift_right(in, shiftamount, out);
    input [66:0] in;        // Changed input width to 66 bits
    input [4:0] shiftamount;
    output [66:0] out;      // Changed output width to 66 bits

    wire [66:0] shifted1, shifted2, shifted4, shifted8, shifted16;
    wire [66:0] out0, out1, out2, out3;

    assign shifted1 = {in[66], in[66:1]};   // Shift by 1 bit, extending the MSB
    mux_2 #(67) mux1(.out(out0), .select(shiftamount[0]), .in0(in), .in1(shifted1));

    assign shifted2 = {{2{out0[66]}}, out0[66:2]}; // Shift by 2 bits, extending the MSB
    mux_2 #(67) mux2(.out(out1), .select(shiftamount[1]), .in0(out0), .in1(shifted2));

    assign shifted4 = {{4{out1[66]}}, out1[66:4]}; // Shift by 4 bits, extending the MSB
    mux_2 #(67) mux3(.out(out2), .select(shiftamount[2]), .in0(out1), .in1(shifted4));

    assign shifted8 = {{8{out2[66]}}, out2[66:8]}; // Shift by 8 bits, extending the MSB
    mux_2 #(67) mux4(.out(out3), .select(shiftamount[3]), .in0(out2), .in1(shifted8));

    assign shifted16 = {{16{out3[66]}}, out3[66:16]}; // Shift by 16 bits, extending the MSB
    mux_2 #(67) mux5(.out(out), .select(shiftamount[4]), .in0(out3), .in1(shifted16));

endmodule
