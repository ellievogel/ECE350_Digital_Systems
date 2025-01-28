`timescale 1 ns / 100 ps

module cla_block_tb;

    reg [7:0] A, B;
    reg Cin;
    wire [7:0] S;
    wire Cout;
    wire [7:0] Gs, Ps;

    // Modules to calculate Gs and Ps
    and_32_bits and_module(
        .result(Gs),
        .A(A),
        .B(B)
    );

    or_32_bits or_module(
        .result(Ps),
        .A(A),
        .B(B)
    );

    // Instantiate the CLA block
    cla_block cla(
        .S(S),
        .Cout(Cout),
        .Cin(Cin),
        .A(A),
        .B(B),
        .Gs(Gs),
        .Ps(Ps)
    );

    initial begin
        A = 8'h00;
        B = 8'h00;
        Cin = 0;
        #640;
        $finish;
    end

    always
        #10 A = ~A;

    always
        #20 B = ~B;

    always
        #40 Cin = ~Cin;

    // Monitor changes and display results
    always @(A, B, Cin) begin
        #1;
        $display("A:%h, B:%h, Cin:%b => S:%h, Cout:%b", 
                A, B, Cin, S, Cout);
        // Additional debug information
        $display("Generate signals: %b", Gs);
        $display("Propagate signals: %b", Ps);
        $display("-----------------------------");
    end

    // Generate waveform file
    initial begin
        $dumpfile("cla_block_wave_file.vcd");
        $dumpvars(0, cla_block_tb);
    end

endmodule
