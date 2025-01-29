`timescale 1 ns / 100 ps

module cla_block_tb;

    reg [7:0] A, B;
    reg Cin;
    wire [7:0] S;
    wire Cout;
    wire [7:0] Gs, Ps;
    wire big_P, big_G;

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
    
    cla_block cla(
        .S(S),
        .Cin(Cin),
        .A(A),
        .B(B),
        .Gs(Gs),
        .Ps(Ps),
        .big_P(big_P),
        .big_G(big_G)
    );

    integer i,j, sum;

    initial begin
        A=0;
        B=0;
        Cin=0;

        for (i=0; i<255; i++) begin
            for (j=0; j<255; j++)begin
                // $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", 
                // A, B, Cin, S, Cout);
                A = i;
                B = j;
                sum = i + j;
                #10;
                if (S != sum) begin
                    $display("wrong");
                    $display("A:%d, B:%d, Cin:%b => S:%d", 
                A, B, Cin, S);
                end
            end
        end
        $finish;
    end

    // always
    //     #10 A = ~A;

    // always
    //     #20 B = ~B;

    // always
    //     #40 Cin = ~Cin;

    // // Monitor changes and display results
    // always @(A, B, Cin) begin
    //     #1;
    //     $display("A:%d, B:%d, Cin:%b => S:%d, Cout:%b", 
    //             A, B, Cin, S, Cout);
    //     // Additional debug information
    //     $display("Generate signals: %b", Gs);
    //     $display("Propagate signals: %b", Ps);
    //     $display("-----------------------------");
    // end

    // Generate waveform file
    initial begin
        $dumpfile("cla_block_wave_file.vcd");
        $dumpvars(0, cla_block_tb);
    end

endmodule
