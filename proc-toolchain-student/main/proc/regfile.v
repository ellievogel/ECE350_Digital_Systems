module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;

	// module register(dataIn, clk, writeEnable, reset, dataOut)

	wire[31:0] write_wires;
	decoder32 write_decoder(.out(write_wires), .select(ctrl_writeReg), .enable(ctrl_writeEnable));

	wire[31:0] read_reg_1_wires;
	decoder32 regA(.out(read_reg_1_wires), .select(ctrl_readRegA), .enable(1'b1));

	wire[31:0] read_reg_2_wires;
	decoder32 regB(.out(read_reg_2_wires), .select(ctrl_readRegB), .enable(1'b1));

	genvar c;
	generate
		for (c=1; c<=31; c = c+1) begin: loop1
			wire[31:0] tempwire;
			register registers(.dataIn(data_writeReg), .clk(clock), .writeEnable(write_wires[c]), .reset(ctrl_reset), .dataOut(tempwire));
			// module my_tri(in, oe, out);
			my_tri temptri1(.in(tempwire), .oe(read_reg_1_wires[c]), .out(data_readRegA));
			my_tri temptri2(.in(tempwire), .oe(read_reg_2_wires[c]), .out(data_readRegB));
		end
	endgenerate

	assign data_readRegA = read_reg_1_wires[0] ? 32'b0 : 32'bz;
	assign data_readRegB = read_reg_2_wires[0] ? 32'b0 : 32'bz;

endmodule
