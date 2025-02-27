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

 // each instruction needs to go through the pipeline in order, regardless of what that is
 // HAZARDS
    // 1. Data Hazard
        // Detecting: compare F/D insn input register names with output register names of older instructions in pipeline
        // (F/D.IR.RS1 == D/X.IR.RD) || (F/D.IR.RS2 == D/X.IR.RD) || (F/D.IR.RS1 == X/M.IR.RD) || (F/D.IR.RS2 == X/M.IR.RD)
        // Use comparators
        // Prevent F/D instruction from reading/advancing this cycle
        // Stall F?D instruction until hazard is resolved
            // write nop into D/X.IR
            // Clear datapath control signals
            // Disable F/D latch and PC write enables
    // 2. Structural Hazard
        // Each instruction uses every structure exactly once
        // For at most once cycle
        // Always at same stage relative to fetch
        // WRITES TO REGISTER FILE ON RISING EDGE
        // READS TO REGISTER FILE ON FALLING EDGE
    // 3. Control Hazard
        // Not resolved until end of stage 3
        // Default: assume branch not taken (can't tell at fetch if it's a branch)
        // If branch is taken, flush pipeline
        // Branch recovery
    
    // Notes on branches:
        // Fast branch: branch is resolved in decode stage
        // Test must be comparison to zero or equality
        // New taken branch penalty: 1 cycle
        // Negative: must be able to bypass into decode now, too, into new dedicated address adder
        // Delayed branches: don't flush instruction immediately following
            // ISA modification (we won't do this)


module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem (instruction)

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem (data)
    wren,                           // O: Write enable for dmem (data)
    q_dmem,                         // I: The data from dmem (data)

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB,                   // I: Data from port B of RegFile
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

    // ================FETCH STAGE=================== //

    wire [31:0] PC_in, PC_out;
    assign address_imem = PC_out;

    register pc(
        .dataIn(PC_in),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(PC_out)
    );

    wire adder_Cout, adder_overflow;
    wire[31:0] PC_incremented;
    assign PC_in = PC_incremented;

    cla adder(
        .S(PC_incremented),
        .Cout(adder_Cout),
        .overflow(adder_overflow),
        .A(PC_out),
        .B(32'b1),
        .Cin(1'b0)
    );

    // FD registers
    wire[31:0] fd_pc, fd_inst;
    register fd_pc_reg(
        .dataIn(PC_out),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(fd_pc)
    );
    register fd_inst_reg(
        .dataIn(q_imem),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(fd_inst)
    );

    // ================DECODE STAGE================== //

    wire [4:0] opcode, rs, rt, rd, shamt, aluop;
    wire [16:0] immediate;
    wire [26:0] target;
    assign opcode = de_inst[31:27];
    assign rd = fd_inst[26:22];
    assign rs = fd_inst[21:17];
    assign rt = fd_inst[16:12];
    assign shamt = fd_inst[11:7];
    assign aluop = fd_inst[6:2];
    assign immediate = fd_inst[16:0];
    assign ctrl_readRegA = rs;
    assign ctrl_readRegB = rt;
    assign target = fd_inst[26:0];

    // DE registers
    wire[31:0] de_regA, de_regB, de_inst;
    register de_regA_reg(
        .dataIn(data_readRegA),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(de_regA)
    );
    register de_regB_reg(
        .dataIn(data_readRegB),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(de_regB)
    );
    register de_inst_reg(
        .dataIn(fd_inst),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(de_inst)
    );

    // ================EXECUTE STAGE================= //
    
    wire[31:0] alu_result, alu_input;
    wire isNotEqual, isLessThan, overflow;
    wire[31:0] sign_extended_immediate;
    wire[4:0] alu_opcode;

    assign sign_extended_immediate = {{15{de_inst[16]}}, de_inst[16:0]};
    assign alu_input = (de_inst[29] == 1'b0) ? de_regB : sign_extended_immediate;
    assign alu_opcode = (de_inst[31:27] == 5'b00101) ? 5'b0 : de_inst[6:2];

    alu alu_unit (
        .data_operandA(de_regA),
        .data_operandB(alu_input),
        .ctrl_ALUopcode(alu_opcode),
        .ctrl_shiftamt(de_inst[11:7]),
        .data_result(alu_result),
        .isNotEqual(isNotEqual),
        .isLessThan(isLessThan),
        .overflow(overflow)
    );

    // EM registers
    wire[31:0] em_alu_result, em_regB, em_inst;
    register em_alu_reg(
        .dataIn(alu_result),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(em_alu_result)
    );
    register em_regB_reg(
        .dataIn(de_regB),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(em_regB)
    );
    register em_inst_reg(
        .dataIn(de_inst),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(em_inst)
    );

    // ================MEMORY STAGE================== //

    assign address_dmem = em_alu_result;
    assign data = em_regB;
    assign wren = (em_inst[31:27] == 5'b00111);

    wire[31:0] mw_alu_result, mw_mem_data, mw_inst;
    register mw_alu_reg(
        .dataIn(em_alu_result),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(mw_alu_result)
    );
    register mw_mem_reg(
        .dataIn(q_dmem),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(mw_mem_data)
    );
    register mw_inst_reg(
        .dataIn(em_inst),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(mw_inst)
    );

    // ================WRITEBACK STAGE=============== //

    // WRITING ON RISING EDGE OF CLOCK CYCLE

    assign ctrl_writeReg = mw_inst[26:22];
    assign ctrl_writeEnable = (mw_inst[31:27] != 5'b00111);
    assign data_writeReg = (mw_inst[31:27] == 5'b00110) ? mw_mem_data : mw_alu_result;

endmodule