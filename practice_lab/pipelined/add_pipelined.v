`timescale 1ns/1ps
module add_pipelined (
    input  wire        clk,
    input  wire        rst_n,
    input  wire  [7:0] a,
    input  wire  [7:0] b,
    input  wire  [7:0] c,
    input  wire  [7:0] d,
    output reg   [9:0] y
);

    reg [8:0] stage1_ab;
    reg [8:0] stage1_cd;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage1_ab <= 9'd0;
            stage1_cd <= 9'd0;
            y         <= 10'd0;
        end else begin
            // Stage 1: Add pairs in parallel
            stage1_ab <= a + b;
            stage1_cd <= c + d;
            
            // Stage 2: Combine the intermediate sums
            y         <= stage1_ab + stage1_cd;
        end
    end

endmodule
