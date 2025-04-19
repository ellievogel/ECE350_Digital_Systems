//module ServoController(
//    input        clk, 		    // System Clock Input 100 Mhz
//    input[9:0]   duty_cycle,	    // Position control switches
//    output       servoSignal    // Signal to the servo
//    );	
        
//    PWMSerializer #(.PERIOD_WIDTH_NS(25'd20000000))
//    serial(.clk(clk), .reset(1'b0), .duty_cycle(duty_cycle), .signal(servoSignal));
    
    
//    ////////////////////
//	// Your Code Here //
//	////////////////////
    
//endmodule

module claw_drop(
    input CLK100MHZ,
    input go,  // single go signal
    input reset,
    output reg jb1,
    output reg claw_up
    );
    

    reg [1:0] step_state = 0;
    reg [31:0] time_counter = 0;
    reg [2:0] fsm_state = 0;
    reg go_prev = 1;
    reg [31:0] pause_counter = 0;
    
    reg [9:0] duty_cycle;
    wire servoSignal;

    PWMSerializer #(.PERIOD_WIDTH_NS(25'd20000000)) serial(.clk(CLK100MHZ), .reset(1'b0), .duty_cycle(duty_cycle), .signal(servoSignal));
    

    parameter STEP_DELAY = 24'd1_000_000;       // ~10ms at 100MHz
    parameter SEVEN_SECONDS = 32'd500_000_000;  // 3s at 100MHz

    reg [23:0] step_delay_counter = 0;

    // FSM states
    localparam IDLE    = 3'd0,
               FORWARD = 3'd1,
               STOP1   = 3'd2,
               BACKWARD= 3'd3,
               DONE    = 3'd4;

    always @(posedge CLK100MHZ) begin
        jb1 <= servoSignal;
    end

    always @(posedge CLK100MHZ) begin
        case (fsm_state)
            IDLE: begin
                claw_up <= 1'd0;
                time_counter <= 0;
                step_delay_counter <= 0;
                pause_counter <= 0;
                if (!go && go_prev)
                    fsm_state <= FORWARD;
            end

            FORWARD: begin
                if (step_delay_counter >= STEP_DELAY) begin
                    step_delay_counter <= 0;
                    step_state <= (step_state == 0) ? 3 : step_state - 1; // CW
                end else begin
                    step_delay_counter <= step_delay_counter + 1;
                end

                time_counter <= time_counter + 1;
                if (time_counter >= SEVEN_SECONDS) begin
                    time_counter <= 0;
                    step_delay_counter <= 0;
                    fsm_state <= STOP1;
                end
            end

            STOP1: begin
                pause_counter <= pause_counter + 1;
                if (pause_counter >= SEVEN_SECONDS) begin
                    time_counter <= 0;
                    step_delay_counter <= 0;
                    fsm_state <= BACKWARD;
                end
            end

            BACKWARD: begin
                if (step_delay_counter >= STEP_DELAY) begin
                    step_delay_counter <= 0;
                    step_state <= (step_state == 3) ? 0 : step_state + 1; // CCW
                end else begin
                    step_delay_counter <= step_delay_counter + 1;
                end

                time_counter <= time_counter + 1;
                if (time_counter >= SEVEN_SECONDS) begin
                    time_counter <= 0;
                    step_delay_counter <= 0;
                    fsm_state <= DONE;
                end
            end

            DONE: begin
                fsm_state <= IDLE;
                claw_up <= 1'd1;
            end
        endcase
//        go_prev <= go;
        // added line
    end

    // OUTPUT: Only one block sets jb1-jb4
    always @(*) begin
        case (fsm_state)
            FORWARD: begin
                 duty_cycle = 10'd100;
            end
            BACKWARD: begin
                 duty_cycle = 10'd50;
            end
            IDLE, STOP1, DONE: begin
                 duty_cycle = 10'd0;      
            end
        endcase
    end
endmodule
