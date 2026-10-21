//=============================================================================
// File        : datapath.v
// Module      : datapath
// Description : Datapath executing ADD (+), SUB (-), MUL (*), DIV (/)
//=============================================================================

module datapath #(
    parameter integer DATA_WIDTH = 4,
    parameter integer OP_WIDTH   = 2
)(
    input                            i_clk,
    input                            i_rst_n,
    input                            i_load_en,
    input                            i_exec_en,
    input  [OP_WIDTH-1:0]            i_op,
    input  [DATA_WIDTH-1:0]          i_data_a,
    input  [DATA_WIDTH-1:0]          i_data_b,
    output reg [(2*DATA_WIDTH)-1:0]  o_result,
    output reg                       o_div_zero_err
);

    reg [DATA_WIDTH-1:0] reg_a;
    reg [DATA_WIDTH-1:0] reg_b;

    always @(posedge i_clk or negedge i_rst_n) begin : dp_proc
        if (!i_rst_n) begin
            reg_a          <= {DATA_WIDTH{1'b0}};
            reg_b          <= {DATA_WIDTH{1'b0}};
            o_result       <= {(2*DATA_WIDTH){1'b0}};
            o_div_zero_err <= 1'b0;
        end else begin
            if (i_load_en) begin
                reg_a <= i_data_a;
                reg_b <= i_data_b;
            end
            if (i_exec_en) begin
                o_div_zero_err <= 1'b0;
                case (i_op)
                    2'b00: begin // ADD
                        o_result <= reg_a + reg_b;
                    end
                    2'b01: begin // SUB
                        o_result <= reg_a - reg_b;
                    end
                    2'b10: begin // MUL
                        o_result <= reg_a * reg_b;
                    end
                    default: begin // DIV (2'b11)
                        if (reg_b != {DATA_WIDTH{1'b0}}) begin
                            o_result <= reg_a / reg_b;
                        end else begin
                            o_result       <= {(2*DATA_WIDTH){1'b0}};
                            o_div_zero_err <= 1'b1;
                        end
                    end
                endcase
            end
        end
    end

endmodule
