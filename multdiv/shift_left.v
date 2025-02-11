// Author: Ellie Vogel (eov2)

module shift_left(in, shiftamount, out);

    input [32:0] in;  
    input [4:0] shiftamount;
    output [32:0] out;

    wire [32:0] shifted1, shifted2, shifted4, shifted8, shifted16;
    wire [32:0] out0, out1, out2, out3;

    assign shifted1 = {in[31:0], 1'b0};  
    mux_2 #(33) mux1(.out(out0), .select(shiftamount[0]), .in0(in), .in1(shifted1));

    assign shifted2 = {out0[30:0], 2'b0};  
    mux_2 #(33) mux2(.out(out1), .select(shiftamount[1]), .in0(out0), .in1(shifted2));

    assign shifted4 = {out1[28:0], 4'b0};  
    mux_2 #(33) mux3(.out(out2), .select(shiftamount[2]), .in0(out1), .in1(shifted4));

    assign shifted8 = {out2[24:0], 8'b0};  
    mux_2 #(33) mux4(.out(out3), .select(shiftamount[3]), .in0(out2), .in1(shifted8));
    
    assign shifted16 = {out3[16:0], 16'b0};  
    mux_2 #(33) mux5(.out(out), .select(shiftamount[4]), .in0(out3), .in1(shifted16));

endmodule
