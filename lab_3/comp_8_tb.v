module comp_8_tb;

    // Declare inputs and outputs for the 8-bit comparator
    reg EQ1, GT1;
    reg [7:0] A, B;
    wire EQ0, GT0;

    // Instantiate the 8-bit comparator
    comp_8 uut(
        .EQ1(EQ1), .GT1(GT1), .A(A), .B(B),
        .EQ0(EQ0), .GT0(GT0)
    );

    // Test procedure
    initial begin
        // Initialize inputs
        EQ1 = 1'b1;
        GT1 = 1'b0;

        // Test case 1: A = 8'b00000000, B = 8'b00000000 (Equal)
        A = 8'b00000000;
        B = 8'b00000000;
        #10; // Wait for the comparator to evaluate
        $display("A = %b, B = %b => EQ0 = %b, GT0 = %b", A, B, EQ0, GT0);

        // Test case 2: A = 8'b01010101, B = 8'b01010101 (Equal)
        A = 8'b01010101;
        B = 8'b01010101;
        #10;
        $display("A = %b, B = %b => EQ0 = %b, GT0 = %b", A, B, EQ0, GT0);

        // Test case 3: A = 8'b11110000, B = 8'b00001111 (A > B)
        A = 8'b11110000;
        B = 8'b00001111;
        #10;
        $display("A = %b, B = %b => EQ0 = %b, GT0 = %b", A, B, EQ0, GT0);

        // Test case 4: A = 8'b00001111, B = 8'b11110000 (A < B)
        A = 8'b00001111;
        B = 8'b11110000;
        #10;
        $display("A = %b, B = %b => EQ0 = %b, GT0 = %b", A, B, EQ0, GT0);

        // Test case 5: A = 8'b10101010, B = 8'b01010101 (A > B)
        A = 8'b10101010;
        B = 8'b01010101;
        #10;
        $display("A = %b, B = %b => EQ0 = %b, GT0 = %b", A, B, EQ0, GT0);

        // Test case 6: A = 8'b11111111, B = 8'b00000000 (A > B)
        A = 8'b11111111;
        B = 8'b00000000;
        #10;
        $display("A = %b, B = %b => EQ0 = %b, GT0 = %b", A, B, EQ0, GT0);

        // Test case 7: A = 8'b00000000, B = 8'b11111111 (A < B)
        A = 8'b00000000;
        B = 8'b11111111;
        #10;
        $display("A = %b, B = %b => EQ0 = %b, GT0 = %b", A, B, EQ0, GT0);

        // Test case 8: A = 8'b01010101, B = 8'b10101010 (A < B)
        A = 8'b01010101;
        B = 8'b10101010;
        #10;
        $display("A = %b, B = %b => EQ0 = %b, GT0 = %b", A, B, EQ0, GT0);
        
        // Test case 9: A = 8'b11100000, B = 8'b11100000 (Equal)
        A = 8'b11100000;
        B = 8'b11100000;
        #10;
        $display("A = %b, B = %b => EQ0 = %b, GT0 = %b", A, B, EQ0, GT0);
        
        // Test case 10: A = 8'b10010010, B = 8'b01101101 (A > B)
        A = 8'b10010010;
        B = 8'b01101101;
        #10;
        $display("A = %b, B = %b => EQ0 = %b, GT0 = %b", A, B, EQ0, GT0);

        // Finish simulation
        $finish;
    end
endmodule
