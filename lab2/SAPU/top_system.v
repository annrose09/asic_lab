module top_system #(
    parameter integer DATA_WIDTH = 4,
    parameter integer OP_WIDTH   = 2
)(
    input                            i_clk,
    input                            i_rst_n,
    input                            i_start,
    input  [OP_WIDTH-1:0]            i_op,
    input  [DATA_WIDTH-1:0]          i_data_a,
    input  [DATA_WIDTH-1:0]          i_data_b,
    output [(2*DATA_WIDTH)-1:0]      o_result,
    output                           o_done,
    output                           o_div_zero_err
);

    wire w_load_en;
    wire w_exec_en;

    controller_fsm ctrl_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_start(i_start),
        .o_load_en(w_load_en),
        .o_exec_en(w_exec_en),
        .o_done(o_done)
    );

    datapath #(
        .DATA_WIDTH(DATA_WIDTH),
        .OP_WIDTH(OP_WIDTH)
    ) dp_inst (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_load_en(w_load_en),
        .i_exec_en(w_exec_en),
        .i_op(i_op),
        .i_data_a(i_data_a),
        .i_data_b(i_data_b),
        .o_result(o_result),
        .o_div_zero_err(o_div_zero_err)
    );

endmodule
