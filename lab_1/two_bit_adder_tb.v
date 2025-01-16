`timescale 1 ns / 100 ps

module full_adder_tb;

    reg A0, A1, B0, B1, Cin;
    wire S0, S1, Cout;

    two_bit_adder adder(.S0(S0), .S1(S1), .Cout(Cout), .A0(A0), .A1(A1), .B0(B0), .B1(B1), .Cin(Cin));

    initial begin
        A0=0;
        A1=0;
        B0=0;
        B1=0;
        Cin=0;
        #320;
        $finish;
    end

    always
        #10 A0 = ~A0;

    always
        #20 A1 = ~A1;

    always
        #40 B0 = ~B0;

    always
        #80 B1 = ~B1;
    
    always
        #120 Cin = ~Cin;



    always @(A0, A1, B0, B1, Cin) begin
        #1;
        $display("A0:%b, A1:%b, B0:%b, B1:%b, Cin:%b => S0:%b, S1:%b, Cout:%b", A0, A1, B0, B1, Cin, S0, S1, Cout);
    end

    initial begin
        $dumpfile("two_bit_adder_wave_file.vcd");
        $dumpvars(0, two_bit_adder_tb);
    end

endmodule