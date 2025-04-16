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

module Wrapper (CLK100MHZ, JB1, JB2, JB3, JB4, input_motor_sig, reset);
    input CLK100MHZ, reset, input_motor_sig;
    output JB1, JB2, JB3, JB4;
    
    wire step_clk;  // Clock for stepper motor controller

    // Clock Divider to slow down the clock if needed (you can adjust frequency here)
    ClockDivider625Hz clkdiv_inst (
        .clk_in(CLK100MHZ), 
        .reset(reset), 
        .clk_out(step_clk)
    );

    // Stepper motor controller
    StepperMotorController stepper_ctrl (
        .clk(step_clk), 
        .reset(reset), 
        .jb1(JB1), 
        .jb2(JB2), 
        .jb3(JB3), 
        .jb4(JB4)
    );
    
//    wire clk_62hz;
//    wire pwm_signal_1, pwm_signal_2, pwm_signal_3, pwm_signal_4;
    
//    ClockDivider625Hz clkdiv_inst (
//        .clk_in(CLK100MHZ),
//        .reset(reset),
//        .clk_out(clk_62hz)
//    );
    
//    PWMSerializer pwm_gen (
//        .clk(clk_62hz),
//        .reset(reset),
//        .duty_cycle(10'd512),  // Example 50% duty cycle
//        .signal(pwm_signal_1)
//    );
    
//    PWMSerializer pwm_gen (
//        .clk(clk_62hz),
//        .reset(reset),
//        .duty_cycle(10'd512),  // Example 50% duty cycle
//        .signal(pwm_signal_2)
//    );
    
//    PWMSerializer pwm_gen (
//        .clk(clk_62hz),
//        .reset(reset),
//        .duty_cycle(10'd512),  // Example 50% duty cycle
//        .signal(pwm_signal_3)
//    );
    
//    PWMSerializer pwm_gen (
//        .clk(clk_62hz),
//        .reset(reset),
//        .duty_cycle(10'd512),  // Example 50% duty cycle
//        .signal(pwm_signal_4)
//    );
    
//    // Output PWM signal to one of the PMOD pins
//    assign JB1 = pwm_signal_1;
//    assign JB2 = pwm_signal_2;
//    assign JB3 = pwm_signal_3;
//    assign JB4 = pwm_signal_4;

    

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
