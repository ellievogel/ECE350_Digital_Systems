// Author: Ellie Vogel (eov2)

module mux_8(out, select, in0, in1, in2, in3, in4, in5, in6, in7);
    input [2:0] select;
    input in0, in1, in2, in3, in4, in5, in6, in7;
    output out;
    wire w1, w2;

    mux_4 first_top(w1, select[1:0], in0, in1, in2, in3);
    mux_4 first_bottom(w2, select[1:0], in4, in5, in6, in7);
    mux_2 second(out, select[2], w1, w2);
endmodule