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

    // ================FETCH STAGE=================== //

    // Latch to store PC and instruction fetched from instruction memory
    
    wire [31:0] PC_in, PC_out;
    assign address_imem = PC_in;
    register pc(
        .dataIn(PC_in),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(PC_out)
    );

    wire[31:0] q_imem_fd_out;
    register fd_latch(
        .dataIn(q_imem),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(q_imem_fd_out)
    );

    wire adder_Cout, adder_overflow;
    wire[31:0] PC_incremented;
    assign PC_in = PC_incremented;

    cla adder(.S(PC_incremented), .Cout(adder_Cout), .overflow(adder_overflow), .A(PC_out), .B(32'b1), .Cin(1'b0));

    // Increment PC by one

    // ================DECODE STAGE================== //

    wire [4:0] opcode, rs, rt, rd, shamt, aluop;
    wire [16:0] immediate;
    assign opcode = q_imem[31:27];
    assign rd = q_imem[26:22]; // Destination Register
    assign rs = q_imem[21:17]; // Register A
    assign rt = q_imem[16:12]; // Register B
    assign shamt = q_imem[11:7];
    assign aluop = q_imem[6:2];
    assign immediate = q_imem[16:0];

    wire[31:0] q_imem_de_out;

    wire[31:0] data_readRegA_out, data_readRegB_out;
    register data_readRegA_latch(
        .dataIn(data_readRegA),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(data_readRegA_out)
    );

    register data_readRegB_latch(
        .dataIn(data_readRegB),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(data_readRegB_out)
    );

    register de_latch(
        .dataIn(q_imem_fd_out),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(q_imem_de_out)
    );

    // ================EXECUTE STAGE================= //

    wire[31:0] alu_result, alu_input;
    wire isNotEqual, isLessThan, overflow;
    wire[31:0] sign_extended_immediate;

    assign sign_extended_immediate = {{15{immediate[16]}}, immediate};

    assign alu_input = (q_imem_de_out[29] == 1'b0) ? data_readRegB_out : sign_extended_immediate;

    alu alu_unit (
        .data_operandA(data_readRegA),
        .data_operandB(alu_input),
        .ctrl_ALUopcode(aluop),
        .ctrl_shiftamt(shamt),
        .data_result(alu_result),
        .isNotEqual(isNotEqual),
        .isLessThan(isLessThan),
        .overflow(overflow)
    );

    wire[31:0] q_imem_em_out;
    register em_latch(
        .dataIn(q_imem_de_out),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(q_imem_em_out)
    );

    // ================MEMORY STAGE================== //

    // Interface with data memory
    // Load/Stores

    wire[31:0] q_imem_mw_out;
    register mw_latch(
        .dataIn(q_imem_em_out),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(q_imem_mw_out)
    );

    // ================WRITEBACK STAGE=============== //

    assign ctrl_writeReg = rd;
    assign ctrl_writeEnable = 1'b1;
    assign data_writeReg = alu_result;
    assign ctrl_readRegA = rs;
    assign ctrl_readRegB = rt;

endmodule