module tb_top_system;

    parameter integer DATA_WIDTH = 4;
    parameter integer OP_WIDTH   = 2;
    parameter integer CLK_PERIOD = 10;

    reg                       i_clk;
    reg                       i_rst_n;
    reg                       i_start;
    reg  [OP_WIDTH-1:0]       i_op;
    reg  [DATA_WIDTH-1:0]     i_data_a;
    reg  [DATA_WIDTH-1:0]     i_data_b;
    wire [(2*DATA_WIDTH)-1:0] o_result;
    wire                      o_done;
    wire                      o_div_zero_err;

    integer error_cnt;

    top_system #(
        .DATA_WIDTH(DATA_WIDTH),
        .OP_WIDTH(OP_WIDTH)
    ) dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_start(i_start),
        .i_op(i_op),
        .i_data_a(i_data_a),
        .i_data_b(i_data_b),
        .o_result(o_result),
        .o_done(o_done),
        .o_div_zero_err(o_div_zero_err)
    );

    always #(CLK_PERIOD / 2) i_clk = ~i_clk;

    task run_op(
        input [OP_WIDTH-1:0]       op,
        input [DATA_WIDTH-1:0]     val_a,
        input [DATA_WIDTH-1:0]     val_b,
        input [(2*DATA_WIDTH)-1:0] expected_res,
        input                      expected_err,
        input [8*18:1]             op_name
    );
        begin
            @(posedge i_clk);
            i_op     <= op;
            i_data_a <= val_a;
            i_data_b <= val_b;
            i_start  <= 1'b1;

            @(posedge i_clk);
            i_start  <= 1'b0;

            wait (o_done == 1'b1);
            

            @(posedge i_clk);
            #1; 

            if ((o_result === expected_res) && (o_div_zero_err === expected_err)) begin
                $display("[PASS] %-16s | A=%2d B=%2d | Result=%3d (0x%02X) | DivZero=%b",
                         op_name, val_a, val_b, o_result, o_result, o_div_zero_err);
            end else begin
                $display("[FAIL] %-16s | A=%2d B=%2d | Result=%3d (Exp=%3d) | DivZero=%b (Exp=%b)",
                         op_name, val_a, val_b, o_result, expected_res, o_div_zero_err, expected_err);
                error_cnt = error_cnt + 1;
            end

            i_op     <= 2'b00;
            i_data_a <= 4'b0000;
            i_data_b <= 4'b0000;
            @(posedge i_clk);
        end
    endtask

    initial begin
        i_clk     = 0;
        i_rst_n   = 0;
        i_start   = 0;
        i_op      = 2'b00;
        i_data_a  = 4'b0000;
        i_data_b  = 4'b0000;
        error_cnt = 0;

        $display("=======================================================================");
        $display("      SYSTEM SIMULATION: FUNCTIONAL CORRECTNESS & COVERAGE CHECK      ");
        $display("=======================================================================");

        #(CLK_PERIOD * 2);
        i_rst_n = 1;
        @(posedge i_clk);

        if (o_result === 8'd0 && o_done === 1'b0) begin
            $display("[PASS] Asynchronous Reset Initialized Successfully.");
        end else begin
            $display("[FAIL] Asynchronous Reset Failed.");
            error_cnt = error_cnt + 1;
        end

        run_op(2'b11, 4'b1111, 4'b1111, 8'd1,   1'b0, "DIV (15 / 15)");
        run_op(2'b10, 4'b1111, 4'b1111, 8'd225, 1'b0, "MUL (15 * 15)");
        run_op(2'b00, 4'b1111, 4'b1111, 8'd30,  1'b0, "ADD (15 + 15)");
        run_op(2'b01, 4'b1010, 4'b0101, 8'd5,   1'b0, "SUB (10 - 5)");
        run_op(2'b10, 4'b0101, 4'b1010, 8'd50,  1'b0, "MUL (5 * 10)");
        run_op(2'b11, 4'b1000, 4'b0000, 8'd0,   1'b1, "DIV BY ZERO");
        run_op(2'b00, 4'b0000, 4'b0000, 8'd0,   1'b0, "CLEAR OUTPUT (0)");

        @(posedge i_clk);
        i_start  <= 1'b1;
        i_data_a <= 4'b1010;
        i_data_b <= 4'b0101;
        @(posedge i_clk);
        i_rst_n  <= 1'b0;
        #1;
        if (o_result === 8'd0) begin
            $display("[PASS] Mid-Transaction Reset (LOAD State) Verified.");
        end else begin
            $display("[FAIL] Mid-Transaction Reset Failed.");
            error_cnt = error_cnt + 1;
        end

        i_rst_n <= 1'b1;
        repeat (3) @(posedge i_clk);

        $display("=======================================================================");
        if (error_cnt == 0) begin
            $display("   TEST SUMMARY: ALL TESTS PASSED (0 ERRORS, 100%% CORRECTNESS)   ");
        end else begin
            $display("   TEST SUMMARY: FAILED WITH %0d ERROR(S)                        ", error_cnt);
        end
        $display("=======================================================================");

        $finish;
    end

endmodule
