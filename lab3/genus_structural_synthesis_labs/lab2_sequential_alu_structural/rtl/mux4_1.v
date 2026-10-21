`timescale 1ns/1ps
module mux4_1 (
    input  wire d0,
    input  wire d1,
    input  wire d2,
    input  wire d3,
    input  wire [1:0] sel,
    output wire y
);
    wire y0, y1;
    mux2_1 m0 (.d0(d0), .d1(d1), .sel(sel[0]), .y(y0));
    mux2_1 m1 (.d0(d2), .d1(d3), .sel(sel[0]), .y(y1));
    mux2_1 m2 (.d0(y0), .d1(y1), .sel(sel[1]), .y(y));
endmodule
