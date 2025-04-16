`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2025 05:27:58 PM
// Design Name: 
// Module Name: claw_movement
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Controls a 4-input stepper motor with simple step sequencing
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Edited
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module claw_movement(
    input CLK100MHZ,
    input input_motor_sig,
    output reg jb1, jb2, jb3, jb4
    );

    reg [1:0] state = 0;
    reg [23:0] delay_counter = 0;

    parameter MAX_COUNT = 24'd8_000_000; // ~100ms delay at 100MHz

    always @(posedge CLK100MHZ) begin
        if (delay_counter == MAX_COUNT) begin
            delay_counter <= 0;

            // Update stepper state based on direction input
            if (input_motor_sig)
                state <= state + 1;
            else
                state <= state - 1;

        end else begin
            delay_counter <= delay_counter + 1;
        end
    end

    // Output coil signals based on stepper state
    always @(*) begin
        case (state)
            2'd0: begin
                jb1 = 1; jb2 = 0; jb3 = 0; jb4 = 0;
            end
            2'd1: begin
                jb1 = 0; jb2 = 1; jb3 = 0; jb4 = 0;
            end
            2'd2: begin
                jb1 = 0; jb2 = 0; jb3 = 1; jb4 = 0;
            end
            2'd3: begin
                jb1 = 0; jb2 = 0; jb3 = 0; jb4 = 1;
            end
            default: begin
                jb1 = 0; jb2 = 0; jb3 = 0; jb4 = 0;
            end
        endcase
    end

endmodule
