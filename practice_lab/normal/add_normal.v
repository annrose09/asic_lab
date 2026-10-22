`timescale 1ns/1ps
module add_normal (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [7:0] c,
    input  wire [7:0] d,
    output wire [9:0] y
);

    assign y = a + b + c + d;

endmodule
