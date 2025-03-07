// Author: Ellie Vogel (eov2)
// dffe_ref (q, d, clk, en, clr);

module register_1_bit(dataIn, clk, writeEnable, reset, dataOut);

    input dataIn;
    input clk, writeEnable, reset;
    output dataOut;

    dffe_ref flipflops(.d(dataIn), .clk(clk), .en(writeEnable), .clr(reset), .q(dataOut));

endmodule
