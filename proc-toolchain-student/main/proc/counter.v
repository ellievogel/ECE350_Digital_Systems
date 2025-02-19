module counter64(clock, reset, count);
    input clock, reset;
    output [5:0] count;

    t_flipflop t1(.toggle(1'b1), .clk(clock), .clear(reset), .q(count[0]));
    t_flipflop t2(.toggle(count[0]), .clk(clock), .clear(reset), .q(count[1]));
    t_flipflop t3(.toggle(count[0] & count[1]), .clk(clock), .clear(reset), .q(count[2]));
    t_flipflop t4(.toggle(count[0] & count[1] & count[2]), .clk(clock), .clear(reset), .q(count[3]));
    t_flipflop t5(.toggle(count[0] & count[1] & count[2] & count[3]), .clk(clock), .clear(reset), .q(count[4]));
    t_flipflop t6(.toggle(count[0] & count[1] & count[2] & count[3] & count[4]), .clk(clock), .clear(reset), .q(count[5]));
    // t_flipflop t7(.toggle(count[0] & count[1] & count[2] & count[3] & count[4] & count[5]), .clk(clock), .clear(reset), .q(count[6]));

endmodule
