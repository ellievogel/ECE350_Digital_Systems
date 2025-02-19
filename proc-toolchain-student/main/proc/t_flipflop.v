module t_flipflop (toggle, clk, clear, q);
    input toggle;
    input clk, clear;
    output q;

    wire data;
    assign data = toggle ? ~q : q;

    dffe_ref register(.q(q), .d(data), .clk(clk), .en(1'b1), .clr(clear));
endmodule