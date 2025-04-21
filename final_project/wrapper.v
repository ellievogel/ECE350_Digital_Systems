`timescale 1ns / 1ps
/**
 * Wrapper module to integrate processor, memory, regfile, and control logic.
 * Modify INSTR_FILE to point to your test program.
 */

module Wrapper (
    input CLK100MHZ,
    input reset,
    input JA7, JA8,
    input [15:0] SW,
    input JD2, // start game
    input JC1, JC2, JC3, JC4, JD1, // joystick + claw controls
    output JB1, JB2, JB3, JB4, // motor outputs
    output JA1, JA2, JA3, JA4, // motor outputs
    output JB7, // claw drop output
    output LED0, LED1, LED2, LED3, LED4, // joystick direction LEDs
    output claw_close // output to close claw
);

    wire [31:0] counter_x, counter_y;
    wire game_over_x, game_over_y, game_over;
    and a(game_over, game_over_x, game_over_y);

    wire claw_up, claw_close_blah;

    // X and Y movement modules
    claw_movement claw_left_right(
        .CLK100MHZ(CLK100MHZ), .stopper_signal(JA8),
        .forwards(JC4), .backwards(JC3),
        .jb1(JA1), .jb2(JA2), .jb3(JA3), .jb4(JA4),
        .start_game(JD2), .claw_dropped(JD1),
        .claw_up(claw_up), .counter(counter_x), .game_over(game_over_x)
    );

    claw_movement claw_forwards_backwards(
        .CLK100MHZ(CLK100MHZ), .stopper_signal(JA7),
        .forwards(JC1), .backwards(JC2),
        .jb1(JB1), .jb2(JB2), .jb3(JB3), .jb4(JB4),
        .start_game(JD2), .claw_dropped(JD1),
        .claw_up(claw_up), .counter(counter_y), .game_over(game_over_y)
    );

    claw_drop blaaah(
        .CLK100MHZ(CLK100MHZ), .go(JD1), .reset(reset),
        .jb1(JB7), .claw_up(claw_up), .claw_close(claw_close_blah)
    );


    wire clk_50;
    wire locked;
    
    clk_wiz_0 pll(.clk_out1(clk_50), .reset(reset), .locked(locked), .clk_in1(CLK100MHZ));
    
    wire clk25;
    wire locked2;
    clk_wiz_4 pll3(.clk_out1(clk6), .reset(reset), .locked(locked2), .clk_in1(CLK100MHZ));
    //clk_wiz_2 pll2(.clk_out1(clk_50), .reset(reset), .locked(locked), .clk_in1(CLK100MHZ));
    assign claw_close = claw_close_blah;

    // CPU <-> Memory signals
    wire rwe, mwe;
    wire [4:0] rd, rs1, rs2;
    wire [31:0] instAddr, instData;
    wire [31:0] rData, regA, regB;
    wire [31:0] memAddr, memDataIn, memDataOut;

    // Register file
    regfile RegisterFile(
        .clock(clk6), .ctrl_reset(reset),
        .ctrl_writeEnable(rwe),
        .ctrl_writeReg(rd),
        .ctrl_readRegA(rs1), .ctrl_readRegB(rs2),
        .data_writeReg(rData),
        .data_readRegA(regA), .data_readRegB(regB)
    );

    // Register to LED display logic based on rs1
    assign LED0 = (rs1 == 5'd13); // Left
    assign LED1 = (rs1 == 5'd6);  // Right
    assign LED2 = (rs1 == 5'd14); // Forwards
    assign LED3 = (rs1 == 5'd15); // Backwards
    assign LED4 = (rs1 == 5'd17); // Claw

    // Memory-mapped I/O
    wire io_read  = (memAddr == 32'd1000);
    wire io_write = (memAddr == 32'd4097);

    reg [15:0] SW_M, SW_Q;
    reg [15:0] LED_reg;

    always @(negedge CLK100MHZ) begin
        SW_M <= SW;
        SW_Q <= SW_M;
    end

    always @(posedge CLK100MHZ) begin
        if (io_write)
            LED_reg <= memDataIn[15:0];
    end

    wire [31:0] memDataOut_from_RAM;
    assign memDataOut = (io_read) ? {16'b0, SW_Q} : memDataOut_from_RAM;

    // RAM with joystick signal injection
    wire joystick_write_enable = JD1 | JD2 | JC1 | JC2 | JC3 | JC4;
    wire [31:0] control_bits = {27'b0, JD1, JC4, JC3, JC1, JC2};

    RAM ProcMem(
        .clk(clk6),
        //.wEn(joystick_write_enable ? 1'b1 : mwe),
        .addr(memAddr[11:0]),
        .dataIn(joystick_write_enable ? control_bits : memDataIn),
        .dataOut(memDataOut_from_RAM)
    );

    // Instruction ROM
    localparam INSTR_FILE = "claw_machine_PLEASE";
    ROM #(.MEMFILE({INSTR_FILE, ".mem"})) InstMem(
        .clk(clk6),
        .addr(instAddr[11:0]),
        .dataOut(instData)
    );

    // CPU instantiation
    processor CPU(
        .clock(clk6), .reset(reset),

        // Instruction memory
        .address_imem(instAddr), .q_imem(instData),

        // Regfile
        .ctrl_writeEnable(rwe), .ctrl_writeReg(rd),
        .ctrl_readRegA(rs1), .ctrl_readRegB(rs2),
        .data_writeReg(rData),
        .data_readRegA(regA), .data_readRegB(regB),

        // Data memory
        .wren(mwe),
        .address_dmem(memAddr),
        .data(memDataIn),
        .q_dmem(memDataOut)
    );

endmodule
