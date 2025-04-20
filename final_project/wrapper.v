`timescale 1ns / 1ps
/**
 *
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor,
 * RegFile and Memory elements together.
 *
 * This file will be used to generate the bitstream to upload to the FPGA.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 *
 * You are allowed to make changes to the Wrapper files for your own testing, but your processor.v
 * and memory modules must work with this Wrapper interface for grading.
 *
 * Refer to Lab 5 documents for details on memory interface. `imem` and `dmem` take 12-bit addresses
 * and store 32-bit values. Memory receives a single clock.
 *
 * Change the INSTR_FILE line below to match your assembled program.
 *
 **/

module Wrapper (
    input CLK100MHZ,
    input reset,
    input JA7, JA8,
    input JD2,         // Button to start game
    input JC1, JC2, JC3, JC4, JD1,
    output JB1, JB2, JB3, JB4,
    output JA1, JA2, JA3, JA4,
    output JB7
);

// ================= CLOCK =================
    wire clock = CLK100MHZ;

// ================= CLAW MOVEMENT MODULES =================
    wire claw_up;

    claw_movement claw_left_right (
        .CLK100MHZ(CLK100MHZ), .stopper_signal(JA8),
        .forwards(JC4), .backwards(JC3),
        .jb1(JA1), .jb2(JA2), .jb3(JA3), .jb4(JA4),
        .start_game(JD2), .claw_dropped(JD1), .claw_up(claw_up)
    );

    claw_movement claw_forwards_backwards (
        .CLK100MHZ(CLK100MHZ), .stopper_signal(JA7),
        .forwards(JC1), .backwards(JC2),
        .jb1(JB1), .jb2(JB2), .jb3(JB3), .jb4(JB4),
        .start_game(JD2), .claw_dropped(JD1), .claw_up(claw_up)
    );

    claw_drop blaaah (
        .CLK100MHZ(CLK100MHZ), .go(JD1), .reset(reset),
        .jb1(JB7), .claw_up(claw_up)
    );

// ================= WIRES FOR PROCESSOR INTERFACES =================
    wire rwe, mwe;
    wire [4:0] rd, rs1, rs2;
    wire [31:0] instAddr, instData;
    wire [31:0] rData, regA, regB;
    wire [31:0] memAddr, memDataIn, memDataOut;

// ================= INSTRUCTION FILE TO LOAD =================
    localparam INSTR_FILE = "claw_machine"; // Change this to match your .mem file name

// ================= JOYSTICK CONTROL SIGNALS TO MEMORY =================
    wire [31:0] control_bits;
    wire [31:0] control_addr = 32'd1000;
    wire [11:0] control_addr_short = control_addr[11:0];

    // Compose control bits from inputs (bit 4: JD1 claw, bits 3–0: directional)
    assign control_bits = {27'b0, JD1, JC4, JC3, JC1, JC2};

    // Enable write to address 1000 if any control signal is active
    wire joystick_write_enable = JD1 | JD2 | JC1 | JC2 | JC3 | JC4;

// ================= MAIN PROCESSING UNIT =================
    processor CPU (
        .clock(clock), .reset(reset),

        // ROM
        .address_imem(instAddr), .q_imem(instData),

        // Regfile
        .ctrl_writeEnable(rwe), .ctrl_writeReg(rd),
        .ctrl_readRegA(rs1), .ctrl_readRegB(rs2),
        .data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),

        // RAM
        .wren(mwe), .address_dmem(memAddr),
        .data(memDataIn), .q_dmem(memDataOut)
    );

// ================= INSTRUCTION MEMORY (ROM) =================
    ROM #(.MEMFILE({INSTR_FILE, ".mem"})) InstMem (
        .clk(clock),
        .addr(instAddr[11:0]),
        .dataOut(instData)
    );

// ================= REGISTER FILE =================
    regfile RegisterFile (
        .clock(clock), .ctrl_writeEnable(rwe), .ctrl_reset(reset),
        .ctrl_writeReg(rd), .ctrl_readRegA(rs1), .ctrl_readRegB(rs2),
        .data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB)
    );

// ================= DATA MEMORY (RAM) =================
    RAM ProcMem (
        .clk(clock),
        .wEn(joystick_write_enable ? 1'b1 : mwe),
        .addr(joystick_write_enable ? control_addr_short : memAddr[11:0]),
        .dataIn(joystick_write_enable ? control_bits : memDataIn),
        .dataOut(memDataOut)
    );

endmodule
