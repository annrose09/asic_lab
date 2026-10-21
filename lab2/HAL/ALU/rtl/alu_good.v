module alu_good #(
    parameter integer DATA_WIDTH = 4,
    parameter integer OP_WIDTH   = 2
)(
    input                       i_clk,
    input                       i_rst_n,
    input  [DATA_WIDTH-1:0]     i_operand_a,
    input  [DATA_WIDTH-1:0]     i_operand_b,
    input  [OP_WIDTH-1:0]       i_alu_op,
    output reg [DATA_WIDTH-1:0] o_alu_result
);
    always @(posedge i_clk or negedge i_rst_n) begin : alu_reg_proc
        if (!i_rst_n) begin
            o_alu_result <= {DATA_WIDTH{1'b0}};
        end else begin
            case (i_alu_op)
                2'b00: begin
                    o_alu_result <= (i_operand_a + i_operand_b)
                                    & {DATA_WIDTH{1'b1}};
                end
                2'b01: begin
                    o_alu_result <= i_operand_a - i_operand_b;
                end
                2'b10: begin
                    o_alu_result <= i_operand_a & i_operand_b;
                end
                default: begin
                    o_alu_result <= i_operand_a | i_operand_b;
                end
            endcase
        end
    end

endmodule
