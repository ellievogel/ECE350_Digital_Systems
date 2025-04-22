module Wrapper (
    input clk_100mhz,
    input BTNU, 
    input [15:0] SW,
    output reg [15:0] LED,
    //input JA1, JA2, JA3, JA4, JA7,
    input JC1, JC2, JC3, JC4, JC7,
    input JA7, JA8,
    output JA1, JA2, JA3, JA4,// output to stepper 1
    output JB1, JB2, JB3, JB4, //output to stepper 2
    input JC8,
    // input JC7, //left button to start game
    output JB7, // output to servo motor
    output JB8 // output to close the claw
);
    wire clock, reset;
    assign clock = clk_100mhz;
    assign reset = BTNU; 
    
    wire rwe, mwe, claw_up;
    wire[4:0] rd, rs1, rs2;
    wire[31:0] instAddr, instData, 
        rData, regA, regB,
        memAddr, memDataIn, memDataOut, q_dmem, data;
    reg [15:0] SW_Q, SW_M;  
    
    wire clk_25, locked;
    clk_wiz_0 pll(clk_25, 1'b0, locked, clk_100mhz); 
    
    wire io_read, io_write;
    
    assign io_read = (memAddr == 32'd10) ? 1'b1 : 1'b0;
    assign io_write = ((memAddr == 32'd20) && mwe) ? 1'b1 : 1'b0;

    wire [31:0] ja_1_2_input;

    assign ja_1_2_input = {27'd0, ~JC7, ~JC4, ~JC3, ~JC2, ~JC1};
    //wire [31:0] ja_1_2_input = {30'b0, 1'b0, 1'b0};
    // Hard-code value 1 at address 4096
    assign q_dmem = (memAddr == 32'd10) ? ja_1_2_input : 
                    (memAddr != 32'd10 && io_read == 1'b1) ? SW_Q : memDataOut;

    // Register the SW input
    always @(negedge clk_25) begin
        SW_M <= SW;
        SW_Q <= SW_M; 
        //ja_12_reg <= {30'd0, JA2, JA1};
    end

    // Output value to LEDs on a write to address 4097
    always @(posedge clk_25) begin
        if (io_write == 1'b1) begin
            //LED <= {memDataIn[15:5], 1'd1, 1'd0, 1'd1, JA2, JA1};
            LED <= memDataIn[15:0];
        end
    end
    
    
    claw_movement claw_left_right(.CLK100MHZ(clk_100mhz), .stopper_signal(JA8), .forwards(JC4), .backwards(JC3), .jb1(JA1), .jb2(JA2), .jb3(JA3), .jb4(JA4), .start_game(JC8), .claw_dropped(JC7), .claw_up(claw_up));
    claw_movement claw_forwards_backwards(.CLK100MHZ(clk_100mhz), .stopper_signal(JA7), .forwards(JC1), .backwards(JC2), .jb1(JB1), .jb2(JB2), .jb3(JB3), .jb4(JB4),.start_game(JC8), .claw_dropped(JC7), .claw_up(claw_up));
    claw_drop blaaah(.CLK100MHZ(clk_100mhz), .go(JC7), .reset(reset), .jb1(JB7), .claw_up(claw_up), .claw_close(JB8));
    //assign memDataIn = {27'd0, 1'd1, 1'd0, 1'd1, JA2, JA1};

    // ADD YOUR MEMORY FILE HERE
    localparam INSTR_FILE = "new_assembly";
    
    // Main Processing Unit
    processor CPU(
        .clock(clk_25), .reset(reset),
        // ROM
        .address_imem(instAddr), .q_imem(instData),
        // Regfile
        .ctrl_writeEnable(rwe), .ctrl_writeReg(rd),
        .ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
        .data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
        // RAM
        .wren(mwe), .address_dmem(memAddr), 
        .data(memDataIn), .q_dmem(q_dmem)
    ); 

    // Instruction Memory (ROM)
    ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
    InstMem(
        .clk(clk_25), 
        .addr(instAddr[11:0]), 
        .dataOut(instData)
    );
    
    // Register File
    regfile RegisterFile(
        .clock(clk_25), 
        .ctrl_writeEnable(rwe), .ctrl_reset(reset), 
        .ctrl_writeReg(rd),
        .ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
        .data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB)
    );
                        
    // Processor Memory (RAM)
    RAM ProcMem(
        .clk(clk_25), 
        .wEn(mwe), 
        .addr(memAddr[11:0]), 
        .dataIn(memDataIn), 
        .dataOut(memDataOut)
    );
    
endmodule
