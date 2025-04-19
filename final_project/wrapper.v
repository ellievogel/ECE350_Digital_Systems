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
 * We will be using our own separate Wrapper_tb.v to test your code. You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 * You must change line 36 to add the memory file of the test you created using the assembler
 * For example, you would add sample inside of the quotes on line 38 after assembling sample.s
 *
 **/

module Wrapper (
    input CLK100MHZ,
    input reset,
    input JA7, JA8,
    input JD2,//button to start game
    input JC1, JC2, JC3, JC4,JD1,
    output JB1, JB2, JB3, JB4,
    output JA1, JA2, JA3, JA4,
    output JB7
    );
   

	// Wire to represent signals (assume JC1=left, JC2=right, JC3=forward, JC4=backward, JC7=claw)
    wire [31:0] control_bits;
    wire [31:0] control_addr = 32'd1000; // Address 1000

    // Combine the signals into a 5-bit pattern and zero-extend to 32 bits
    // CHANGE THIS ELLIE VOGEL
    assign control_bits = {27'b0, JC2, JC2, JC1, JC3, JC4}; 
    // Bit 4: JD1 (claw)
    // Bit 3: JC2 (backward)
    // Bit 2: JC1 (forward)
    // Bit 1: JC3 (left)
    // Bit 0: JC4 (right)

    // Drive the memory input signals manually
    wire manual_write_en = 1'b1; // Always write for this use case
    wire [11:0] control_addr_short = control_addr[11:0];

    // RAM module updated to include our override for this signal
    RAM ProcMem(
        .clk(clock),
        .wEn(mwe | manual_write_en),
        .addr(mwe ? memAddr[11:0] : control_addr_short),
        .dataIn(mwe ? memDataIn : control_bits),
        .dataOut(memDataOut)
    );

    claw_movement claw_left_right(.CLK100MHZ(CLK100MHZ), .stopper_signal(JA8), .forwards(JC4), .backwards(JC3), .jb1(JA1), .jb2(JA2), .jb3(JA3), .jb4(JA4), .start_game(JD2), .claw_dropped(JD1), .claw_up(claw_up));
    
    claw_movement claw_forwards_backwards(.CLK100MHZ(CLK100MHZ), .stopper_signal(JA7), .forwards(JC1), .backwards(JC2), .jb1(JB1), .jb2(JB2), .jb3(JB3), .jb4(JB4), .start_game(JD2), .claw_dropped(JD1), .claw_up(claw_up));
    wire claw_up;
    // wire[9:0] duty_cycle = 10'd30;
    claw_drop blaaah(.CLK100MHZ(CLK100MHZ), .go(JD1), .reset(reset), .jb1(JB7), .claw_up(claw_up));
    // ServoController servo(.clk(CLK100MHZ), .duty_cycle(duty_cycle), .servoSignal(JB7));
//    wire[9:0] duty_cycle = 9'd512;

//    PWMSerializer serializer (.clk(CLK100MHZ), .reset(reset), .duty_cycle(duty_cycle), .signal(pwm_signal));

	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut;


	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "claw_machine";
	
	// Main Processing Unit
	processor CPU(.clock(clock), .reset(reset), 
								
		// ROM
		.address_imem(instAddr), .q_imem(instData),
									
		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
									
		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataIn), .q_dmem(memDataOut)); 
	
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clock), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));
	
	// Register File
	regfile RegisterFile(.clock(clock), 
		.ctrl_writeEnable(rwe), .ctrl_reset(reset), 
		.ctrl_writeReg(rd),
		.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB));
						
	// // Processor Memory (RAM)
	// RAM ProcMem(.clk(clock), 
	// 	.wEn(mwe), 
	// 	.addr(memAddr[11:0]), 
	// 	.dataIn(memDataIn), 
	// 	.dataOut(memDataOut));

endmodule
