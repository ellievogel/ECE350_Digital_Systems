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
    data_readRegB,                  // I: Data from port B of RegFile
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
    wire stall;

    register pc(
        .dataIn(PC_in),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(PC_out)
    );

    wire adder_Cout, adder_overflow;
    wire[31:0] PC_incremented;

    wire[31:0] corrected_data_readRegA = ((ctrl_writeReg == ctrl_readRegA) && ctrl_writeEnable && ctrl_writeReg != 5'b00000) ? data_writeReg : data_readRegA;
    wire[31:0] corrected_data_readRegB = ((ctrl_writeReg == ctrl_readRegB) && ctrl_writeEnable && ctrl_writeReg != 5'b00000) ? data_writeReg : data_readRegB;

    cla adder(
        .S(PC_incremented),
        .Cout(adder_Cout),
        .overflow(adder_overflow),
        .A(PC_out),
        .B(32'b1),
        .Cin(1'b0)
    );

    // FD registers
    wire[31:0] fd_pc, raw_fd_inst;
    register fd_pc_reg(
        .dataIn(PC_out),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(fd_pc)
    );

    wire flush;
    wire [31:0] modified_q_imem;
    assign modified_q_imem = flush ? 32'b0 : q_imem;

    register fd_inst_reg(
        .dataIn(modified_q_imem),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(raw_fd_inst)
    );
    wire[31:0] fd_pc_incremented;
    register fd_pc_plus_one(
        .dataIn(PC_incremented),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(fd_pc_incremented)
    );


    // ================DECODE STAGE================== //

    wire[31:0] fd_inst = flush ? 32'b0 : raw_fd_inst;

    wire [4:0] opcode, rs, rt, rd, shamt, aluop;
    wire [16:0] immediate;
    wire [26:0] target;
    assign opcode = fd_inst[31:27];
    assign rd = fd_inst[26:22];
    assign rs = fd_inst[21:17];
    assign rt = fd_inst[16:12];
    assign shamt = fd_inst[11:7];
    assign aluop = fd_inst[6:2];
    assign immediate = fd_inst[16:0];

    wire is_blt, is_bne, read_rd, is_jr;
    assign is_blt = (fd_inst[31:27] == 5'b00110);
    assign is_bne = (fd_inst[31:27] == 5'b00010);
    assign is_jr = (fd_inst[31:27] == 5'b00100);
    wire is_sw_decode;
    assign is_sw_decode = (fd_inst[31:27] == 5'b00111); // Opcode for sw
    assign read_rd = is_blt || is_bne || is_jr || is_sw_decode;
    

    wire[4:0] writeReg_input;

    // assign readReg1_input = (opcode == 5'b00111 || opcode == 5'b01000) ? rd : rs;
    // assign readReg2_input = (opcode == 5'b00111 || opcode == 5'b01000) ? rs : rt;
    assign writeReg_input = (opcode == 5'b00111) ? 5'b00000 : rd;

    wire read_thirty = opcode == 5'b10110;
    assign ctrl_readRegA = read_thirty ? 5'b11110 : ((1'b0) ? rd : rs);
    assign ctrl_readRegB = read_rd ? rd : ((opcode == 5'b00111 || opcode == 5'b01000) ? rs : rt);
    assign target = fd_inst[26:0];

    // DE registers
    wire[31:0] de_regA, de_regB, de_inst, PC_de;
    register de_regA_reg(
        .dataIn(corrected_data_readRegA),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(de_regA)
    );
    register de_regB_reg(
        .dataIn(corrected_data_readRegB),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(de_regB)
    );


    // wire[31:0] flushed_decode_instruction;
    // mux_2 flush_decode_mux(
    //     .out(flushed_decode_instruction),
    //     .select(flush),
    //     .in0(fd_inst),
    //     .in1(32'b0)
    // );

    register de_inst_reg(
        .dataIn(fd_inst),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(de_inst)
    );
    register de_pc(
        .dataIn(fd_pc),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(PC_de)
    );
    wire[31:0] PC_incremented_de;
    register pc_plus_one(
        .dataIn(fd_pc_incremented),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(PC_incremented_de)
    );  

    wire[4:0] de_readReg1, de_readReg2, de_writeReg;

    // WORKING VERSION
    // assign readReg1_input = rs;
    // assign readReg2_input = rt;
    // assign writeReg_input = rd;


    register_parameter #(5) fd_readReg1_reg(
        .dataIn(ctrl_readRegA),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(de_readReg1)
    );
    register_parameter #(5) fd_readReg2_reg(
        .dataIn(ctrl_readRegB),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(de_readReg2)
    );
    register_parameter #(5) fd_writeReg_reg(
        .dataIn(writeReg_input),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(de_writeReg)
    );


    // ================EXECUTE STAGE================= //
    
    wire is_blt_execute, is_bne_execute, is_jr_execute, jal;
    assign is_blt_execute = (de_inst[31:27] == 5'b00110);
    assign is_bne_execute = (de_inst[31:27] == 5'b00010);
    assign is_jr_execute = (de_inst[31:27] == 5'b00100);
    assign jal = (de_inst[31:27] == 5'b00011);
    wire[31:0] exception_value;

    wire[31:0] sign_extended_immediate;
    wire[31:0] computed_mem_address;
    assign computed_mem_address = alu_result;

    wire[31:0] em_bypass_de_regA, mw_bypass_de_regA;
    assign mw_bypass_de_regA = ew_bypass_1 ? data_writeReg : de_regA;
    assign em_bypass_de_regA = em_bypass_1 ? q_dmem_corrected : de_regA;
    wire[31:0] bypass_de_regA = em_bypass_1 ? em_bypass_de_regA : mw_bypass_de_regA;

    wire[31:0] em_bypass_de_regB, mw_bypass_de_regB;
    assign mw_bypass_de_regB = ew_bypass_2 ? data_writeReg : de_regB;
    assign em_bypass_de_regB = em_bypass_2 ? q_dmem_corrected : de_regB;
    wire[31:0] bypass_de_regB = em_bypass_2 ? em_bypass_de_regB : mw_bypass_de_regB;

    wire[31:0] alu_result, alu_input;
    wire isNotEqual, isLessThan, overflow;
    wire[4:0] alu_opcode, alu_opcode_intermediate;

    assign sign_extended_immediate = {{15{de_inst[16]}}, de_inst[16:0]};
    assign alu_input = (de_inst[31:27] == 5'b00101 || de_inst[31:27] == 5'b00111 || de_inst[31:27] == 5'b01000) 
                        ? sign_extended_immediate : bypass_de_regB;

    assign alu_opcode_intermediate = (de_inst[31:27] == 5'b00000) ? de_inst[6:2] : 5'b00000;
    assign alu_opcode = (is_blt_execute || is_bne_execute) ? 5'b00001 : alu_opcode_intermediate;

    wire is_all_zeros = (bypass_de_regA == 32'd0);
    wire[4:0] de_opcode = de_inst[31:27];
    wire is_jump = (de_inst[31:27] == 5'b00001 || jal);  // J or JAL
    wire is_bex = (de_inst[31:27] == 5'b10110) && (~is_all_zeros);

    wire is_blt_branch = is_blt_execute && isLessThan;
    wire is_bne_branch = is_bne_execute && isNotEqual;

    wire[31:0] final_ALU_A = is_blt_execute ? alu_input : bypass_de_regA;
    wire[31:0] final_ALU_B = is_blt_execute ? bypass_de_regA : alu_input;

    wire take_branch = is_jump || is_bex || is_blt_branch || is_bne_branch;
    wire[31:0] jump_target = {5'b0, de_inst[26:0]};
    wire[31:0] next_pc = take_branch ? jump_target : PC_incremented;
    wire[31:0] jr_destination = bypass_de_regB;
    wire[31:0] bne_destination;
    wire[31:0] branch_pc = (is_blt_branch || is_bne_branch) ? bne_destination : next_pc;
    assign PC_in = is_jr_execute ? jr_destination : branch_pc;

    assign flush = is_jump || is_bex || is_blt_branch || is_bne_branch || is_jr_execute;

    wire adder_bne_Cout, adder_bne_overflow;
    cla adder_bne(
        .S(bne_destination),
        .Cout(adder_bne_Cout),
        .overflow(adder_bne_overflow),
        .A(PC_incremented_de),
        .B(sign_extended_immediate),
        .Cin(1'b0)
    );

    // ALU instance
    alu alu_unit (
        .data_operandA(final_ALU_A),
        .data_operandB(final_ALU_B),
        .ctrl_ALUopcode(alu_opcode),
        .ctrl_shiftamt(de_inst[11:7]),
        .data_result(alu_result),
        .isNotEqual(isNotEqual),
        .isLessThan(isLessThan),
        .overflow(overflow)
    );


    wire is_add_overflow = (de_opcode == 5'b00000) && (alu_opcode == 5'b00000) && overflow;
    wire is_addi_overflow = (de_opcode == 5'b00101) && overflow;
    wire is_sub_overflow = (de_opcode == 5'b00000) && (alu_opcode == 5'b00001) && overflow;

    wire mult = alu_opcode == 5'b00110 && de_inst[31:27] == 5'b00000;
    wire div = alu_opcode == 5'b00111 && de_inst[31:27] == 5'b00000;
    wire multdiv_exception, multdiv_resultRDY;
    wire[31:0] multdiv_result;

    wire is_mult_exception = mult && multdiv_exception;
    wire is_div_exception = div && multdiv_exception;

    assign exception_value = is_mult_exception ? 32'b00000000000000000000000000000100 : (is_div_exception ? 32'b00000000000000000000000000000101 : (is_add_overflow ? 32'b00000000000000000000000000000001 : (is_addi_overflow ? 32'b00000000000000000000000000000010 : (is_sub_overflow ? 32'b00000000000000000000000000000011 : 32'b00000000000000000000000000000000))));
    wire[31:0] exception_with_setX = execute_is_setx ? jump_target : exception_value;
    wire is_multiplying;
    assign stall = stall_logic || ((mult || div) && ~multdiv_resultRDY);

    register_parameter #(1) dff(
        .dataIn((mult || div) && ~multdiv_resultRDY),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(is_multiplying)
    );

    multdiv multiply_divide(
        .data_operandA(final_ALU_A),
        .data_operandB(final_ALU_B), 
        .ctrl_MULT(mult && ~is_multiplying),
        .ctrl_DIV(div && ~is_multiplying),
        .clock(clock), 
        .data_result(multdiv_result), 
        .data_exception(multdiv_exception),
        .data_resultRDY(multdiv_resultRDY)
    );

    wire exception;
    assign exception = is_add_overflow || is_addi_overflow || is_sub_overflow || is_mult_exception || is_div_exception;

    // EM registers
    wire[31:0] em_alu_result, em_regB, em_inst, PC_em;

    wire[31:0] alu_with_jal, alu_result_multdiv;
    assign alu_result_multdiv = (mult || div) ? multdiv_result : alu_result;

    
    assign alu_with_jal = jal ? PC_incremented_de : alu_result_multdiv; 

    wire execute_is_setx = (de_inst[31:27] == 5'b10101);
    wire[31:0] alu_exception_output = (exception || execute_is_setx) ? exception_with_setX : alu_with_jal;

    wire[4:0] exception_de_writeReg = jal ? 5'b11111 : ((exception || execute_is_setx) ? 5'b11110 : de_writeReg);

    wire[31:0] bypass_em_regA, bypass_em_regB;
    register bypass_de_regA_reg(
        .dataIn(bypass_de_regA),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(bypass_em_regA)
    );
    register bypass_de_regB_reg(
        .dataIn(bypass_de_regB),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(bypass_em_regB)
    );
    register em_alu_reg(
        .dataIn(alu_exception_output),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(em_alu_result)
    );
    wire em_exception;
    register_1_bit exception_or_not_em(
        .dataIn(exception),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(em_exception)
    );
    wire[31:0] em_exception_value;
    register em_exception_value_reg(
        .dataIn(exception_value),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(em_exception_value)
    );
    register em_regB_reg(
        .dataIn(de_regB),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(em_regB)
    );
    wire[31:0] de_inst_stalled = stall ? 32'b0 : de_inst;
    register em_inst_reg(
        .dataIn(de_inst_stalled),
        .clk(~clock),
        .writeEnable(1'b1),
        .reset(reset),
        .dataOut(em_inst)
    );
    register em_pc(
        .dataIn(PC_de),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(PC_em)
    );
    wire[31:0] PC_incremented_em;
    register pc_plus_one_em(
        .dataIn(PC_incremented_de),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(PC_incremented_em)
    );
    wire[31:0] sw_em_address;
    register sw_em(
        .dataIn(computed_mem_address),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(sw_em_address)
    );

    // Hazard registers
    wire[4:0] em_readReg1, em_readReg2, em_writeReg;
    register_parameter #(5) de_readReg1_reg(
        .dataIn(de_readReg1),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(em_readReg1)
    );
    register_parameter #(5) de_readReg2_reg(
        .dataIn(de_readReg2),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(em_readReg2)
    );
    register_parameter #(5) de_writeReg_reg(
        .dataIn(exception_de_writeReg),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(em_writeReg)
    );


    // ================MEMORY STAGE================== //

    wire is_sw_memory = (em_inst[31:27] == 5'b00111);

    assign address_dmem = sw_em_address;
    // assign data = em_bypass_regB;
    assign wren = is_sw_memory;

    wire[31:0] mw_alu_result, mw_mem_data, mw_inst, PC_mw;
    register mw_alu_reg(
        .dataIn(em_alu_result),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(mw_alu_result)
    );

    assign data = bypass_em_regB;
    wire[31:0] q_dmem_corrected = (em_inst[31:27] == 5'b01000) ? q_dmem : em_alu_result;

    register mw_mem_reg(
        .dataIn(q_dmem_corrected),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(mw_mem_data)
    );
    register mw_inst_reg(
        .dataIn(em_inst),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(mw_inst)
    );
    register mw_pc(
        .dataIn(PC_em),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(PC_mw)
    );
    wire mw_exception;
    register_1_bit exception_or_not_mw(
        .dataIn(em_exception),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(mw_exception)
    );
    wire[31:0] mw_exception_value;
    register mw_exception_value_reg(
        .dataIn(em_exception_value),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(mw_exception_value)
    );
    wire[31:0] PC_incremented_mw;
    register pc_plus_one_mw(
        .dataIn(PC_incremented_em),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(PC_incremented_mw)
    );
    wire[31:0] mw_regB;
    wire[31:0] em_bypass_regB = mw_bypass ? data_writeReg : em_regB;
    register mw_regB_reg(
        .dataIn(em_bypass_regB),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(mw_regB)
    );

    // Hazard registers
    wire[4:0] mw_readReg1, mw_readReg2, mw_writeReg;
    register_parameter #(5) em_readReg1_reg(
        .dataIn(em_readReg1),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(mw_readReg1)
    );
    register_parameter #(5) em_readReg2_reg(
        .dataIn(em_readReg2),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(mw_readReg2)
    );
    register_parameter #(5) em_writeReg_reg(
        .dataIn(em_writeReg),
        .clk(~clock),
        .writeEnable(~stall),
        .reset(reset),
        .dataOut(mw_writeReg)
    );


    // ================WRITEBACK STAGE=============== //

    // WRITING ON RISING EDGE OF CLOCK CYCLE

    wire [31:0] jump_target_mw = {mw_inst[26], mw_inst[26], mw_inst[26], mw_inst[26], mw_inst[26], mw_inst[26:0]};
    wire mw_jal = (mw_inst[31:27] == 5'b00011);
    // wire exception;
    // assign exception = is_add_overflow || is_addi_overflow || is_sub_overflow || is_mult_exception || is_div_exception;

    // Write to register 30 for setx, register 31 for jal, otherwise use mw_inst[26:22]
    // CHANGED
    // assign ctrl_writeReg = (setx || mw_exception) ? 5'b11110 : (mw_jal ? 5'b11111 : mw_inst[26:22]);
    assign ctrl_writeReg = mw_writeReg;

    // Enable write for setx, jal, or any instruction except bne (00010)
    assign ctrl_writeEnable = mw_exception || (mw_inst[31:27] == 5'b00011) || (mw_inst[31:27] == 5'b00000) || (mw_inst[31:27] == 5'b00101) || (mw_inst[31:27] == 5'b01000) || (mw_inst[31:27] == 5'b10101);
    
    // wire[31:0] memory_data = (mw_inst[31:27] == 5'b01000) ? mw_mem_data : mw_alu_result;

    wire adder_mw_Cout, adder_mw_overflow;
    wire[31:0] PC_mw_incremented;
    
    cla adder_mw(
        .S(PC_mw_incremented),
        .Cout(adder_mw_Cout),
        .overflow(adder_mw_overflow),
        .A(PC_mw),
        .B(32'b1),
        .Cin(1'b0)
    );

    // wire[31:0] exception_value_to_write = mw_exception ? mw_exception_value : jump_target_mw;
    assign data_writeReg = mw_mem_data;

    // ================BYPASSING/STALLING=============== //

    wire inst_in_memory_writes_to_register = ((em_inst[31:27] != 5'b00111) && (em_inst[31:27] != 5'b00001) && (em_inst[31:27] != 5'b00010) && (em_inst[31:27] != 5'b00100) && (em_inst[31:27] != 5'b00110) && (em_inst[31:27] != 5'b10110));

    wire em_bypass_1, em_bypass_2, ew_bypass_1, ew_bypass_2, mw_bypass;
    assign em_bypass_1 = (de_readReg1 == em_writeReg) && inst_in_memory_writes_to_register && (de_readReg1 != 5'b00000) && (em_writeReg != 5'b00000);
    assign em_bypass_2 = (de_readReg2 == em_writeReg) && inst_in_memory_writes_to_register && (de_readReg2 != 5'b00000) && (em_writeReg != 5'b00000);
    assign ew_bypass_1 = (de_readReg1 == mw_writeReg) && ctrl_writeReg && (de_readReg1 != 5'b00000) && (mw_writeReg != 5'b00000);
    assign ew_bypass_2 = (de_readReg2 == mw_writeReg) && ctrl_writeReg && (de_readReg2 != 5'b00000) && (mw_writeReg != 5'b00000);
    assign mw_bypass = (mw_readReg1 == ctrl_writeReg) && (mw_readReg1 != 5'b00000) && (ctrl_writeReg != 5'b00000);
    
    wire lw_in_memory = em_inst[31:27] == 5'b01000;
    wire de_rs_uses_lw_rd = (de_inst[21:17] == em_writeReg) && em_inst[31:27] == 5'b01000;
    wire de_rt_uses_lw_rd = (de_inst[16:12] == em_writeReg) && em_inst[31:27] == 5'b01000;
    wire inst_uses_rs = (de_inst[31:27] == 5'b00000) || // All R-type instructions use rs
                    (de_inst[31:27] == 5'b00101) || // addi
                    (de_inst[31:27] == 5'b00111) || // sw
                    (de_inst[31:27] == 5'b01000) || // lw
                    (de_inst[31:27] == 5'b00010) || // bne
                    (de_inst[31:27] == 5'b00110) || // blt
                    (de_inst[31:27] == 5'b00100);   // jr

    wire inst_uses_rt = ((de_inst[31:27] == 5'b00000) &&  // R-type instructions that use rt
                     ((de_inst[6:2] == 5'b00000) ||  // add
                      (de_inst[6:2] == 5'b00001) ||  // sub
                      (de_inst[6:2] == 5'b00010) ||  // and
                      (de_inst[6:2] == 5'b00011) ||  // or
                      (de_inst[6:2] == 5'b00110) ||  // mul
                      (de_inst[6:2] == 5'b00111)))   // div
                    || (de_inst[31:27] == 5'b00101)  // addi
                    || (de_inst[31:27] == 5'b00010)  // bne
                    || (de_inst[31:27] == 5'b00110); // blt

    wire stall_logic = 1'b0; // stall if operation in memory is lw and operation in execute is alu

endmodule