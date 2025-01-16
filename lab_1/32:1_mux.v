// Author: Ellie Vogel (eov2)

module mux_2(out, select, in0, in1);
    input select;
    input [31:0] in0, in1;
    output [31:0] out;
    assign out = select ? in1 : in0;
endmodule

module mux_4 (out, select, in0, in1, in2, in3);
    input [1:0] select;
    input [31:0] in0, in1, in2, in3;
    output [31:0] out;
    wire [31:0] w1, w2;
    mux_2 first_top(w1, select[0], in0, in1);
    mux_2 first_bottom(w2, select[1], in2, in3);
    mux_2 second(out, select[1], w1, w2);
endmodule

module mux_8(out, select, in0, in1, in2, in3, in4, in5, in6, in7);
    input [2:0] select;
    input [31:0] in0, in1, in2, in3, in4, in5, in6, in7;
    output [31:0] out;
    wire [31:0] w1, w2;

    mux_4 first_top(w1, select[1:0], in0, in1, in2, in3);
    mux_4 first_bottom(w2, select[1:0], in4, in5, in6, in7);
    mux_2 second(out, select[2], w1, w2);
endmodule

module mux_32(out, select, 
              in0, in1, in2, in3, in4, in5, in6, in7,
              in8, in9, in10, in11, in12, in13, in14, in15,
              in16, in17, in18, in19, in20, in21, in22, in23,
              in24, in25, in26, in27, in28, in29, in30, in31);
    input [4:0] select;
    input [31:0] in0, in1, in2, in3, in4, in5, in6, in7;
    input [31:0] in8, in9, in10, in11, in12, in13, in14, in15;
    input [31:0] in16, in17, in18, in19, in20, in21, in22, in23;
    input [31:0] in24, in25, in26, in27, in28, in29, in30, in31;
    output [31:0] out;
    wire [31:0] w1, w2, w3, w4;

    mux_8 mux_top_left(w1, select[2:0], in0, in1, in2, in3, in4, in5, in6, in7);
    mux_8 mux_top_right(w2, select[2:0], in8, in9, in10, in11, in12, in13, in14, in15);
    mux_8 mux_bottom_left(w3, select[2:0], in16, in17, in18, in19, in20, in21, in22, in23);
    mux_8 mux_bottom_right(w4, select[2:0], in24, in25, in26, in27, in28, in29, in30, in31);
    mux_4 mux_final(out, select[4:3], w1, w2, w3, w4);
endmodule