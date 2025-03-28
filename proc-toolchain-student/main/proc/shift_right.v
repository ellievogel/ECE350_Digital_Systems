// Author: Ellie Vogel (eov2)

module shift_right(in, shiftamount, out);
    input [31:0] in;
    input [4:0] shiftamount;
    output [31:0] out;

    wire [31:0] shifted1, shifted2, shifted4, shifted8, shifted16;
    wire [31:0] out0, out1, out2, out3;

    assign shifted1 = {in[31], in[31:1]};
    mux_2 mux1(.out(out0), .select(shiftamount[0]), .in0(in), .in1(shifted1));

    assign shifted2 = {{2{out0[31]}}, out0[31:2]};
    mux_2 mux2(.out(out1), .select(shiftamount[1]), .in0(out0), .in1(shifted2));

    assign shifted4 = {{4{out1[31]}}, out1[31:4]};
    mux_2 mux3(.out(out2), .select(shiftamount[2]), .in0(out1), .in1(shifted4));

    assign shifted8 = {{8{out2[31]}}, out2[31:8]};
    mux_2 mux4(.out(out3), .select(shiftamount[3]), .in0(out2), .in1(shifted8));

    assign shifted16 = {{16{out3[31]}}, out3[31:16]};
    mux_2 mux5(.out(out), .select(shiftamount[4]), .in0(out3), .in1(shifted16));

endmodule
