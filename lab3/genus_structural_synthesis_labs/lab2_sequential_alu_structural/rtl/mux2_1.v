`timescale 1ns/1ps
module mux2_1 (
    input  wire d0,
    input  wire d1,
    input  wire sel,
    output wire y
);
    wire nsel, w0, w1;
    not (nsel, sel);
    and (w0, d0, nsel);
    and (w1, d1, sel);
    or  (y, w0, w1);
endmodule
