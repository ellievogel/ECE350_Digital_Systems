`timescale 1 ns / 100 ps

module moore_mod5_tb;

    reg clk, reset, button;
    wire [2:0] count;
    wire trigger;

    moore_mod5_counter moore_counter (
        .clk(clk), .reset(reset), .button(button),
        .count(count), .trigger(trigger)
    );

    initial begin
        clk = 0;
        reset = 1;
        button = 0;

        #10 reset = 0;  // Release reset

        // Simulate button presses to increment the counter
        #10 button = 1; #10 button = 0;
        #10 button = 1; #10 button = 0;
        #10 button = 1; #10 button = 0;
        #10 button = 1; #10 button = 0;
        #10 button = 1; #10 button = 0;  // Reaches 4

        #20 $finish;
    end

    always #5 clk = ~clk; // Generate clock signal

    always @(posedge clk) begin
        $display("Time: %0t | Count = %d, Trigger = %b", $time, count, trigger);
    end

    initial begin
        $dumpfile("moore_mod5_wave.vcd");
        $dumpvars(0, moore_mod5_tb);
    end

endmodule
