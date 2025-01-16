`timescale 1 ns / 100 ps

module mux_32_tb;

    reg [31:0] in0, in1, in2, in3, in4, in5, in6, in7;
    reg [31:0] in8, in9, in10, in11, in12, in13, in14, in15;
    reg [31:0] in16, in17, in18, in19, in20, in21, in22, in23;
    reg [31:0] in24, in25, in26, in27, in28, in29, in30, in31;
    reg [4:0] select;
    wire [31:0] out;

    mux_32 mux(.out(out), .select(select),
               .in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7),
               .in8(in8), .in9(in9), .in10(in10), .in11(in11), .in12(in12), .in13(in13), .in14(in14), .in15(in15),
               .in16(in16), .in17(in17), .in18(in18), .in19(in19), .in20(in20), .in21(in21), .in22(in22), .in23(in23),
               .in24(in24), .in25(in25), .in26(in26), .in27(in27), .in28(in28), .in29(in29), .in30(in30), .in31(in31));

    initial begin
    // Initialize inputs in decimal
        in0 = 32'd1;
        in1 = 32'd2;
        in2 = 32'd4;
        in3 = 32'd8;
        in4 = 32'd16;
        in5 = 32'd32;
        in6 = 32'd64;
        in7 = 32'd128;
        in8 = 32'd256;
        in9 = 32'd512;
        in10 = 32'd1024;
        in11 = 32'd2048;
        in12 = 32'd4096;
        in13 = 32'd8192;
        in14 = 32'd16384;
        in15 = 32'd32768;
        in16 = 32'd65536;
        in17 = 32'd131072;
        in18 = 32'd262144;
        in19 = 32'd524288;
        in20 = 32'd1048576;
        in21 = 32'd2097152;
        in22 = 32'd4194304;
        in23 = 32'd8388608;
        in24 = 32'd16777216;
        in25 = 32'd33554432;
        in26 = 32'd67108864;
        in27 = 32'd134217728;
        in28 = 32'd268435456;
        in29 = 32'd536870912;
        in30 = 32'd1073741824;
        in31 = 32'd2147483648;
        select = 5'b00000;
        
        #320;
        $finish;
    end

    always
        #10 select = select + 1;

    always @(select) begin
        #5;
        $display("Select:%b => Out:%h", select, out);
    end

    initial begin
        $dumpfile("mux_32_wave_file.vcd");
        $dumpvars(0, mux_32_tb);
    end

endmodule
