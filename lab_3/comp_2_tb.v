`timescale 1ns / 1ps

module comp_2_tb;
    reg EQ1, GT1;
    reg [1:0] A, B;
    wire EQ0, GT0;

    // Instantiate the Unit Under Test (UUT)
    comp_2 uut (
        .EQ1(EQ1),
        .GT1(GT1),
        .A(A),
        .B(B),
        .EQ0(EQ0),
        .GT0(GT0)
    );

    initial begin
        // Print table header
        $display("EQ(i+1) GT(i+1) A1 A0 B1 B0 | EQ(i) GT(i)");
        $display("------------------------------------------");

        // Test cases from the given truth table
        EQ1 = 0; GT1 = 0; A = 2'bxx; B = 2'bxx; #10;
        $display("   %b       %b      x  x  x  x  |   %b     %b", EQ1, GT1, EQ0, GT0);

        EQ1 = 0; GT1 = 1; A = 2'bxx; B = 2'bxx; #10;
        $display("   %b       %b      x  x  x  x  |   %b     %b", EQ1, GT1, EQ0, GT0);

        EQ1 = 1; GT1 = 0; A = 2'b00; B = 2'b00; #10;
        $display("   %b       %b      0  0  0  0  |   %b     %b", EQ1, GT1, EQ0, GT0);

        EQ1 = 1; GT1 = 0; A = 2'b00; B = 2'b01; #10;
        $display("   %b       %b      0  0  0  1  |   %b     %b", EQ1, GT1, EQ0, GT0);

        EQ1 = 1; GT1 = 0; A = 2'b01; B = 2'b00; #10;
        $display("   %b       %b      0  1  0  0  |   %b     %b", EQ1, GT1, EQ0, GT0);

        EQ1 = 1; GT1 = 0; A = 2'b01; B = 2'b01; #10;
        $display("   %b       %b      0  1  0  1  |   %b     %b", EQ1, GT1, EQ0, GT0);

        EQ1 = 1; GT1 = 0; A = 2'b0x; B = 2'b1x; #10;
        $display("   %b       %b      0  x  1  x  |   %b     %b", EQ1, GT1, EQ0, GT0);

        EQ1 = 1; GT1 = 0; A = 2'b1x; B = 2'b0x; #10;
        $display("   %b       %b      1  x  0  x  |   %b     %b", EQ1, GT1, EQ0, GT0);

        EQ1 = 1; GT1 = 0; A = 2'b10; B = 2'b10; #10;
        $display("   %b       %b      1  0  1  0  |   %b     %b", EQ1, GT1, EQ0, GT0);

        EQ1 = 1; GT1 = 0; A = 2'b10; B = 2'b11; #10;
        $display("   %b       %b      1  0  1  1  |   %b     %b", EQ1, GT1, EQ0, GT0);

        EQ1 = 1; GT1 = 0; A = 2'b11; B = 2'b10; #10;
        $display("   %b       %b      1  1  1  0  |   %b     %b", EQ1, GT1, EQ0, GT0);

        EQ1 = 1; GT1 = 0; A = 2'b11; B = 2'b11; #10;
        $display("   %b       %b      1  1  1  1  |   %b     %b", EQ1, GT1, EQ0, GT0);

        EQ1 = 1; GT1 = 1; A = 2'bxx; B = 2'bxx; #10;
        $display("   %b       %b      x  x  x  x  |   %b     %b", EQ1, GT1, EQ0, GT0);

        $finish;
    end
endmodule
