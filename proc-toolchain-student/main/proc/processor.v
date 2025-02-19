/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	/* YOUR CODE STARTS HERE */

    wire [4:0] opcode, rs, rt, rd, shamt, aluop;
    assign opcode = q_imem[31:27];
    assign rd = q_imem[26:22]; // Destination Register
    assign rs = q_imem[21:17]; // Register A
    assign rt = q_imem[16:12]; // Register B
    assign shamt = q_imem[11:7];
    assign aluop = q_imem[6:2];

    wire[31:0] alu_result;
    wire isNotEqual, isLessThan, overflow;

    alu alu_unit (
        .data_operandA(data_readRegA),
        .data_operandB(data_readRegB),
        .ctrl_ALUopcode(aluop),
        .ctrl_shiftamt(shamt),
        .data_result(alu_result),
        .isNotEqual(isNotEqual),
        .isLessThan(isLessThan),
        .overflow(overflow)
    );

    assign ctrl_writeEnable = (opcode == 5'b00000) ? 1 : 0;
    assign ctrl_writeReg = rd;
    assign data_writeReg = alu_result;

	
	/* END CODE */

    // add $rd, $rs, $rt: 00000 (00000 ALUOP) (R)
    // addi $rd, $rs, N: 00101 (I)
    // sub $rd, $rs, $rt: 00000 (00001 ALUOP) (R)

    // Opcode = instruction[31:27]
    // Rd = instruction[26:22]
    // Rs = instruction[21:17]
    // Rt = instruction[16:12]
    // Shamt = instruction[11:7]
    // ALUOp = instruction[6:2]

    // Imm = instruction[16:0]

endmodule
