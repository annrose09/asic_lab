`timescale 1ns/1ps
module alu4_comb_structural (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [1:0] opcode,
    output wire [3:0] result,
    output wire       carry
);
    // opcode: 00 ADD, 01 SUB, 10 AND, 11 OR
    wire [3:0] b_inv;
    wire [3:0] b_arith;
    wire [3:0] arithmetic_result;
    wire [3:0] and_result;
    wire [3:0] or_result;
    wire       arithmetic_carry;
    wire       sub_sel;
    wire       carry_selected;

    assign sub_sel = opcode[0] & ~opcode[1];

    not (b_inv[0], b[0]);
    not (b_inv[1], b[1]);
    not (b_inv[2], b[2]);
    not (b_inv[3], b[3]);

    mux2_1 mb0 (.d0(b[0]), .d1(b_inv[0]), .sel(sub_sel), .y(b_arith[0]));
    mux2_1 mb1 (.d0(b[1]), .d1(b_inv[1]), .sel(sub_sel), .y(b_arith[1]));
    mux2_1 mb2 (.d0(b[2]), .d1(b_inv[2]), .sel(sub_sel), .y(b_arith[2]));
    mux2_1 mb3 (.d0(b[3]), .d1(b_inv[3]), .sel(sub_sel), .y(b_arith[3]));

    ripple_adder4 u_addsub (
        .a(a), .b(b_arith), .cin(sub_sel),
        .sum(arithmetic_result), .cout(arithmetic_carry)
    );

    and (and_result[0], a[0], b[0]);
    and (and_result[1], a[1], b[1]);
    and (and_result[2], a[2], b[2]);
    and (and_result[3], a[3], b[3]);

    or  (or_result[0], a[0], b[0]);
    or  (or_result[1], a[1], b[1]);
    or  (or_result[2], a[2], b[2]);
    or  (or_result[3], a[3], b[3]);

    mux4_1 mr0 (.d0(arithmetic_result[0]), .d1(arithmetic_result[0]),
                .d2(and_result[0]), .d3(or_result[0]), .sel(opcode), .y(result[0]));
    mux4_1 mr1 (.d0(arithmetic_result[1]), .d1(arithmetic_result[1]),
                .d2(and_result[1]), .d3(or_result[1]), .sel(opcode), .y(result[1]));
    mux4_1 mr2 (.d0(arithmetic_result[2]), .d1(arithmetic_result[2]),
                .d2(and_result[2]), .d3(or_result[2]), .sel(opcode), .y(result[2]));
    mux4_1 mr3 (.d0(arithmetic_result[3]), .d1(arithmetic_result[3]),
                .d2(and_result[3]), .d3(or_result[3]), .sel(opcode), .y(result[3]));

    // Carry is meaningful only for ADD/SUB.
    mux2_1 mc0 (.d0(arithmetic_carry), .d1(1'b0), .sel(opcode[1]), .y(carry_selected));
    assign carry = carry_selected;
endmodule
