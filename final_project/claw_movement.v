module claw_movement(
    input CLK100MHZ,
    input forwards,
    input backwards,
    input claw_dropped,
    input claw_up,
    input stopper_signal,
    input start_game,
    output reg jb1, jb2, jb3, jb4
    );

    reg [1:0] state = 0;
    reg [23:0] delay_counter = 0;

    parameter MAX_COUNT = 24'd1_000_000; // ~10ms delay at 100MHz

    wire move_enable = (forwards ^ backwards) && stopper_signal;  // Move only if one is high
    wire direction = forwards;               // 1 = CW, 0 = CCW
    
    reg [1:0] fsm_state = 0;
    localparam OFF    = 3'd0,
               GAME = 3'd1,
               CLAW_DROP = 3'd2,
               END   = 3'd3;

    always @(posedge CLK100MHZ) begin
        case(fsm_state) 
            OFF: begin
                if (~start_game)
                    fsm_state <= GAME;
            end
            GAME: begin
                if (~claw_dropped) 
                    fsm_state <= CLAW_DROP; 
                if (delay_counter == MAX_COUNT) begin
            delay_counter <= 0;

            if (move_enable) begin
                if (direction)
                    state <= (state == 3) ? 0 : state + 1; // CW
                else
                    state <= (state == 0) ? 3 : state - 1; // CCW
            end

        end else begin
            delay_counter <= delay_counter + 1;
        end
            end
           CLAW_DROP: begin
                if (claw_up) 
                fsm_state <= END;
           end
           END: begin
           
            if (delay_counter == MAX_COUNT) begin
            delay_counter <= 0;

            // if (move_enable) begin
            begin
                //if (direction)
                   state <= (state == 3) ? 0 : state + 1; // CW
               // else
                   // state <= (state == 0) ? 3 : state - 1; // CCW
            end

        end else begin
            delay_counter <= delay_counter + 1;
        if (!stopper_signal) 
            fsm_state <= OFF;
        end
           end
            endcase
    end

    // Step sequence (full-step, 4-phase)
    always @(*) begin
        case(fsm_state) 
            GAME, END: begin
                case (state)
                    2'd0: begin jb1 = 1; jb2 = 0; jb3 = 0; jb4 = 1; end
                    2'd1: begin jb1 = 1; jb2 = 0; jb3 = 1; jb4 = 0; end
                    2'd2: begin jb1 = 0; jb2 = 1; jb3 = 1; jb4 = 0; end
                    2'd3: begin jb1 = 0; jb2 = 1; jb3 = 0; jb4 = 1; end
                endcase
            end 
            OFF, CLAW_DROP: begin
                {jb1, jb2, jb3, jb4} = 4'd0;
            end
        endcase
    end

endmodule
