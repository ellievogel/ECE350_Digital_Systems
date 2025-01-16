`timescale 1 ns / 100 ps

module mux_4_tb;

    reg [31:0] in0, in1, in2, in3;
    reg [1:0] select;
    wire [31:0] out;

    mux_4 mux(.out(out), .select(select),
              .in0(in0), .in1(in1), .in2(in2), .in3(in3));

    initial begin
        // Initialize inputs in decimal
        in0 = 32'd1;
        in1 = 32'd2;
        in2 = 32'd4;
        in3 = 32'd8;
        select = 2'b00;
        
        #40;
        $finish;
    end

    always
        #10 select = select + 1;

    always @(select) begin
        #5;
        $display("Select:%b => Out:%h", select, out);
    end

    initial begin
        $dumpfile("mux_4_wave_file.vcd");
        $dumpvars(0, mux_4_tb);
    end

endmodule
