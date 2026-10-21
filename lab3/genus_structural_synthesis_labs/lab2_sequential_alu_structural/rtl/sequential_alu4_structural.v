`timescale 1ns/1ps
module sequential_alu4_structural (
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [1:0] opcode,
    output wire [3:0] result,
    output wire       carry
);
    wire [3:0] next_result;
    wire       next_carry;

    alu4_comb_structural u_core (
        .a(a), .b(b), .opcode(opcode),
        .result(next_result), .carry(next_carry)
    );

    dff_async_reset q0 (.clk(clk), .rst(rst), .d(next_result[0]), .q(result[0]));
    dff_async_reset q1 (.clk(clk), .rst(rst), .d(next_result[1]), .q(result[1]));
    dff_async_reset q2 (.clk(clk), .rst(rst), .d(next_result[2]), .q(result[2]));
    dff_async_reset q3 (.clk(clk), .rst(rst), .d(next_result[3]), .q(result[3]));
    dff_async_reset qc (.clk(clk), .rst(rst), .d(next_carry),   .q(carry));
endmodule
