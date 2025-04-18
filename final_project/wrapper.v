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
    input JC1, JC2, JC3, JC4,// JC1 = left, JC2 = right, JC3 = up, JC4 = down
    input JD1,
    output JB1, JB2, JB3, JB4,
    output JA1, JA2, JA3, JA4,
    output JB7, JB8, JB9, JB10
    
    );

    // output JB7, JB8, JB9, JB10;
    
//    assign input_motor_sig = 1;
// Query register 1 to see whether or not to move claw
    
    // move left/right
    claw_movement claw_left_right(.CLK100MHZ(CLK100MHZ),.stopper_signal(JA8), .forwards(JC4), .backwards(JC3), .jb1(JA1), .jb2(JA2), .jb3(JA3), .jb4(JA4));
    // Write values to registers with movement
    
    
    // move forwards/backwards
    claw_movement claw_forwards_backwards(.CLK100MHZ(CLK100MHZ), .stopper_signal(JA7), .forwards(JC1), .backwards(JC2), .jb1(JB1), .jb2(JB2), .jb3(JB3), .jb4(JB4));
     
    //claw_movement claw_up_down(.CLK100MHZ(CLK100MHZ), .stopper_signal(JA7), .forwards(1'b1), .backwards(JD1), .jb1(JB7), .jb2(JB8), .jb3(JB9), .jb4(JB10));
    claw_drop blahhhh(.CLK100MHZ(CLK100MHZ), .go(JD1),.jb1(JB7), .jb2(JB8), .jb3(JB9), .jb4(JB10));
    // JB7, JB8, JB9, JB10 outputs
    // JC7 is button, JC8 is high
    
    // claw_drop claw_drop_and_up(.CLK100MHZ(CLK100MHZ), .go(JC7), .jb1(JB7), .jb2(JB8), .jb3(JB9), .jb4(JB10));

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
						
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock), 
		.wEn(mwe), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn), 
		.dataOut(memDataOut));

endmodule
