`timescale 1 ns / 100 ps

module one_bit_adder_tb;

    reg A, B, Cin;
    wire S, Cout;

    one_bit_adder adder(.A(A), .B(B), .Cin(Cin), .S(S), .Cout(Cout));

    initial begin
        A=0;
        B=0;
        Cin=0;
        #80;
        $finish;
    end

    always
        #10 A = ~A;

    always
        #20 B = ~B;

    always
        #40 Cin = ~Cin;

    always @(A, B, Cin) begin
        #1;
        $display("A:%b, B:%b, Cin:%b => S:%b, Cout:%b", A, B, Cin, S, Cout);
    end

    initial begin
        $dumpfile("one_bit_adder_wave_file.vcd");
        $dumpvars(0, one_bit_adder_tb);
    end

endmodule