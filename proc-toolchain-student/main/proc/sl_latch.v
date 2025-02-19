module sl_latch(R, S, Qa, Qb);

    input R, S;
    output Qa, Qb;

    wire nor_1;
    wire nor_3;
    nor(nor_1, R, nor_3);
    nor(nor_3, S, nor_1);

    assign Qa = nor_1;
    assign Qb = nor_3;

endmodule