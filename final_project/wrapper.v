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

module Wrapper (input CLK100MHZ,
    input reset,
//    input [15:0] SW, 
    input JA8, input JC4, input JC3, input JD2, output JA1, output JA2, output JA3, output JA4,
    input JD1, JC1, JC2,
    output reg LED0, output reg LED1, output reg LED2, 
    output LED3, 
    output LED4);
    

	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut, q_dmem, reg6, reg6_m;
    
    wire locked, clk_25, clock;
    clk_wiz_0 pll(clk_25, 1'b0, locked, CLK100MHZ);
    assign clock = clk_25;
    
    wire io_read, poop;
    assign io_read = 1'b0;
    wire io_write;
    assign io_write = (memAddr[11:0] == 12'd6) && mwe == 1'b1;
    
    wire [31:0] control_bits;
    assign control_bits = {27'b0, JD1, JC4, JC3, JC1, JC2};
    
//    assign LED0 = 1'b1;
//    assign LED1 = memDataIn[0];
//    assign LED2 = memDataIn[0];
//    assign LED3 = memDataIn[0];
//    assign LED4 = memDataIn[0];
    
    always @(posedge clock) begin
     if (io_write) begin
        //LED <= memDataIn[15:0];
         LED0 <=1'b1; // right
         LED1 <= memDataIn[0];  // left
         
//         LED3 <= memDataIn[0]; // Backwards
//         LED4 <= memDataIn[0]; // Claw
     end
     LED2 <= reg6_m[0]; // Forwards
    end
//    assign LED2 = io_write ? memDataIn[0] : LED2;
    assign LED3 = reg6_m[0];
    assign LED4 = poop;
    //assign q_dmem = io_read ? {16'd0, SW[15:0]} : memDataOut;
    assign q_dmem = memDataOut;
    wire[31:0] memDataIn_new  = (memAddr[11:0] == 12'd6) ? control_bits : memDataIn;
    
//    claw_movement claw_left_right(
//        .CLK100MHZ(clock), .stopper_signal(JA8),
//        .forwards(JC4), .backwards(JC3),
//        .jb1(JA1), .jb2(JA2), .jb3(JA3), .jb4(JA4),
//        .start_game(JD2), .claw_dropped(1'd0),
//        .claw_up(1'd0)
//    );

	// ADD YOUR MEMORY FILE HERE
	localparam INSTR_FILE = "easyish";
	
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
		.data(memDataIn), .q_dmem(q_dmem)); 
	
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
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB), .reg6(reg6));
						
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clock), 
		.wEn(mwe), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn_new),
		.button(reg6_m), .poop(poop),
		.dataOut(memDataOut));

endmodule
