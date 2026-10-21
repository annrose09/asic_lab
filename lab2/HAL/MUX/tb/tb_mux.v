module tb_mux_good;

    parameter integer DATA_WIDTH = 4;
    parameter integer CLK_PERIOD = 10;

    reg                       i_clk;
    reg                       i_rst_n;
    reg  [DATA_WIDTH-1:0]     i_data_a;
    reg  [DATA_WIDTH-1:0]     i_data_b;
    reg                       i_sel;
    wire [DATA_WIDTH-1:0]     o_data_y;

    integer error_cnt;

    mux_good #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_data_a(i_data_a),
        .i_data_b(i_data_b),
        .i_sel(i_sel),
        .o_data_y(o_data_y)
    );

    always #(CLK_PERIOD / 2) i_clk = ~i_clk;

    task check_mux(
        input [DATA_WIDTH-1:0] a,
        input [DATA_WIDTH-1:0] b,
        input                  sel,
        input [DATA_WIDTH-1:0] expected_out
    );
        begin
            @(posedge i_clk);
            i_data_a <= a;
            i_data_b <= b;
            i_sel    <= sel;

            @(posedge i_clk);
            #1;

            if (o_data_y === expected_out) begin
                $display("[PASS] Sel=%b | A=%d B=%d => Output=%d (Expected=%d)", 
                         sel, a, b, o_data_y, expected_out);
            end else begin
                $display("[FAIL] Sel=%b | A=%d B=%d => Output=%d (Expected=%d)", 
                         sel, a, b, o_data_y, expected_out);
                error_cnt = error_cnt + 1;
            end
        end
    endtask

    initial begin
        i_clk     = 0;
        i_rst_n   = 0;
        i_data_a  = 0;
        i_data_b  = 0;
        i_sel     = 0;
        error_cnt = 0;

        $display("--------------------------------------------------");
        $display("      Starting Synchronous MUX Functional Test    ");
        $display("--------------------------------------------------");

        #(CLK_PERIOD * 2);
        i_rst_n = 1;
        @(posedge i_clk);
        if (o_data_y !== {DATA_WIDTH{1'b0}}) begin
            $display("[FAIL] Reset test failed! Output = %b", o_data_y);
            error_cnt = error_cnt + 1;
        end else begin
            $display("[PASS] Reset Test Passed.");
        end

        check_mux(4'd3, 4'd8, 1'b0, 4'd8);

        check_mux(4'd3, 4'd8, 1'b1, 4'd3);

        check_mux(4'd14, 4'd2, 1'b1, 4'd14);

        check_mux(4'd14, 4'd2, 1'b0, 4'd2);

        @(posedge i_clk);
        i_rst_n <= 0;
        #1;
        if (o_data_y === {DATA_WIDTH{1'b0}}) begin
            $display("[PASS] Async Reset Test Passed.");
        end else begin
            $display("[FAIL] Async Reset Test Failed.");
            error_cnt = error_cnt + 1;
        end

        $display("--------------------------------------------------");
        if (error_cnt == 0)
            $display("   ALL MUX TESTS PASSED SUCCESSFULLY (0 ERRORS)   ");
        else
            $display("   TEST FAILED WITH %0d ERROR(S)", error_cnt);
        $display("--------------------------------------------------");

        $finish;
    end

endmodule
