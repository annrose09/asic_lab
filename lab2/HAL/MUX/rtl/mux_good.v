module mux_good #(
    parameter integer DATA_WIDTH = 4
)(
    input                       i_clk,
    input                       i_rst_n,
    input  [DATA_WIDTH-1:0]     i_data_a,
    input  [DATA_WIDTH-1:0]     i_data_b,
    input                       i_sel,
    output reg [DATA_WIDTH-1:0] o_data_y
);

    always @(posedge i_clk or negedge i_rst_n) begin : mux_reg_proc
        if (!i_rst_n) begin
            o_data_y <= {DATA_WIDTH{1'b0}};
        end else begin
            if (i_sel) begin
                o_data_y <= i_data_a;
            end else begin
                o_data_y <= i_data_b;
            end
        end
    end

endmodule
