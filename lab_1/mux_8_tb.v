`timescale 1 ns / 100 ps

module mux_8_tb;

    reg [31:0] in0, in1, in2, in3, in4, in5, in6, in7;
    reg [2:0] select;
    wire [31:0] out;

    mux_8 mux(.out(out), .select(select),
              .in0(in0), .in1(in1), .in2(in2), .in3(in3),
              .in4(in4), .in5(in5), .in6(in6), .in7(in7));

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
        select = 3'b000;
        
        #80;
        $finish;
    end

    always
        #10 select = select + 1;

    always @(select) begin
        #5;
        $display("Select:%b => Out:%h", select, out);
    end

    initial begin
        $dumpfile("mux_8_wave_file.vcd");
        $dumpvars(0, mux_8_tb);
    end

endmodule
