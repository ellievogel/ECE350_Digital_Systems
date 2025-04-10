module moore_mod5_counter (
    input clk, reset, button,
    output reg [2:0] count,
    output reg trigger
);
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            count <= 0;
        else if (button)
            count <= (count == 4) ? 0 : count + 1;
    end

    always @(posedge clk) begin
        trigger <= (count == 4);
    end

endmodule
