// Author: Ellie Vogel (eov2)
// dffe_ref (q, d, clk, en, clr);

module register_parameter #(parameter WIDTH = 66)(dataIn, clk, writeEnable, reset, dataOut);

    input[WIDTH-1:0] dataIn;
    input clk, writeEnable, reset;
    output[WIDTH-1:0] dataOut;

    genvar c;
    generate
        for (c=0; c<=WIDTH-1; c = c+1) begin: loop1
            dffe_ref flipflops(.d(dataIn[c]), .clk(clk), .en(writeEnable), .clr(reset), .q(dataOut[c]));
        end
    endgenerate

endmodule