`timescale 1 ns / 100 ps
module comp_8_tb;

    reg EQ1, GT1;
    integer x; 
    reg [7:0] A, B;
    wire EQ0, GT0; 

    comp_8 comp(.EQ1(EQ1), .GT1(GT1), .A(A), .B(B), .EQ0(EQ0), .GT0(GT0)); 

    initial begin
        // Initialize inputs
        EQ1 = 1'b1;  
        GT1 = 1'b0;
        A = 8'b00000000;
        B = 8'b00000000;
        x = 3'd0;
        
        // Test equality cases
        for (A = 0; x < 256; A = A + 51) begin  // Test every 51st value
            B = A;  // Test equality
            #10;
            
            B = A + 1;  // Test A < B
            #10;
            
            B = A - 1;  // Test A > B
            #10;

            x = x + 51;
        end

        // Test cascade inputs
        A = 8'h55; B = 8'h55;  // Equal values
        EQ1 = 1'b0; GT1 = 1'b0; #10;  // Test LT cascade
        EQ1 = 1'b0; GT1 = 1'b1; #10;  // Test GT cascade
        EQ1 = 1'b1; GT1 = 1'b0; #10;  // Test EQ cascade

        // Display test completion
        $display("Test completed");
        $finish;
    end

    // Monitor for failures
    always @(EQ0 or GT0) begin
        // Check equality failure
        if ((EQ1 == 1 && GT1 == 0 && EQ0 == 1) && (A != B)) begin
            $display("Failed Equality: A=%h B=%h are not equal but EQ0=1 at time%0t", A, B, $time);
        end
    end

    // Generate VCD file
    initial begin
        $dumpfile("comp_8_dump.vcd");
        $dumpvars(0, comp_8_tb);
    end

endmodule