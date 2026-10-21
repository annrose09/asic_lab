module tb_alu_good;

    parameter integer DATA_WIDTH = 4;
    parameter integer OP_WIDTH   = 2;
    parameter integer CLK_PERIOD = 10;

    reg                       i_clk;
    reg                       i_rst_n;
    reg  [DATA_WIDTH-1:0]     i_operand_a;
    reg  [DATA_WIDTH-1:0]     i_operand_b;
    reg  [OP_WIDTH-1:0]       i_alu_op;
    wire [DATA_WIDTH-1:0]     o_alu_result;

    integer error_cnt;

    alu_good #(
        .DATA_WIDTH(DATA_WIDTH),
        .OP_WIDTH(OP_WIDTH)
    ) dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_operand_a(i_operand_a),
        .i_operand_b(i_operand_b),
        .i_alu_op(i_alu_op),
        .o_alu_result(o_alu_result)
    );

    always #(CLK_PERIOD / 2) i_clk = ~i_clk;

    task check_alu(
        input [DATA_WIDTH-1:0] a,
        input [DATA_WIDTH-1:0] b,
        input [OP_WIDTH-1:0]   op,
        input [DATA_WIDTH-1:0] expected_out,
        input [8*10:1]         op_name
    );
        begin
            @(posedge i_clk);
            i_operand_a <= a;
            i_operand_b <= b;
            i_alu_op    <= op;

            @(posedge i_clk);
            #1;

            if (o_alu_result === expected_out) begin
                $display("[PASS] Op: %s | A=%d B=%d => Result=%d (Expected=%d)", 
                         op_name, a, b, o_alu_result, expected_out);
            end else begin
                $display("[FAIL] Op: %s | A=%d B=%d => Result=%d (Expected=%d)", 
                         op_name, a, b, o_alu_result, expected_out);
                error_cnt = error_cnt + 1;
            end
        end
    endtask

    initial begin
        i_clk       = 0;
        i_rst_n     = 0;
        i_operand_a = 0;
        i_operand_b = 0;
        i_alu_op    = 0;
        error_cnt   = 0;

        $display("--------------------------------------------------");
        $display("      Starting Synchronous ALU Functional Test     ");
        $display("--------------------------------------------------");

        #(CLK_PERIOD * 2);
        i_rst_n = 1;
        @(posedge i_clk);
        if (o_alu_result !== 4'b0000) begin
            $display("[FAIL] Reset test failed! Result = %b", o_alu_result);
            error_cnt = error_cnt + 1;
        end else begin
            $display("[PASS] Reset Test Passed.");
        end

        check_alu(4'd5, 4'd3, 2'b00, 4'd8, "ADD");
        check_alu(4'd15, 4'd3, 2'b00, 4'd2, "ADD_OVERFLOW");

        check_alu(4'd9, 4'd4, 2'b01, 4'd5, "SUB");

        check_alu(4'b1100, 4'b1010, 2'b10, 4'b1000, "AND");

        check_alu(4'b1100, 4'b0011, 2'b11, 4'b1111, "OR");

        @(posedge i_clk);
        i_rst_n <= 0;
        #1;
        if (o_alu_result === 4'b0000) begin
            $display("[PASS] Async Reset Mid-Op Passed.");
        end else begin
            $display("[FAIL] Async Reset Mid-Op Failed.");
            error_cnt = error_cnt + 1;
        end

        $display("--------------------------------------------------");
        if (error_cnt == 0)
            $display("   ALL TESTS PASSED SUCCESSFULLY (0 ERRORS)");
        else
            $display("   TEST FAILED WITH %0d ERROR(S)", error_cnt);
        $display("--------------------------------------------------");

        $finish;
    end

endmodule
