// Author: Ellie Vogel (eov2)
// dffe_ref (q, d, clk, en, clr);

module register(dataIn, clk, writeEnable, reset, dataOut);

    input[31:0] dataIn;
    input clk, writeEnable, reset;
    output[31:0] dataOut;

    genvar c;
    generate
        for (c=0; c<=31; c = c+1) begin: loop1
            dffe_ref flipflops(.d(dataIn[c]), .clk(clk), .en(writeEnable), .clr(reset), .q(dataOut[c]));
        end
    endgenerate

endmodule