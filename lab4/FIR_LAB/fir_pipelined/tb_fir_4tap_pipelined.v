`timescale 1ns/1ps

module tb_fir_4tap_pipelined;

    reg clk;
    reg rst;
    reg signed [7:0] xin;
    wire signed [17:0] yout;

    integer error_count;
    integer checked_count;
    integer input_count;

    // Reference FIR delay line
    reg signed [7:0] ref_x1, ref_x2, ref_x3;

    // Expected-output pipeline matching the two-clock DUT latency
    reg signed [17:0] expected_now;
    reg signed [17:0] expected_d1;
    reg signed [17:0] expected_d2;
    reg               valid_d1;
    reg               valid_d2;

    fir_4tap_pipelined dut (
        .clk  (clk),
        .rst  (rst),
        .xin  (xin),
        .yout (yout)
    );

    // 100 MHz clock: 10 ns period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    task apply_sample;
        input signed [7:0] sample;
        begin
            @(negedge clk);
            xin = sample;

            // Golden direct-form FIR result for the sample being applied
            expected_now = (sample * 4) + (ref_x1 * 3)
                         - ref_x2 - (ref_x3 * 2);

            @(posedge clk);
            #1;

            // yout corresponds to the result entered two clocks earlier
            if (valid_d2) begin
                checked_count = checked_count + 1;
                if (yout !== expected_d2) begin
                    $display("FAIL: output=%0d expected=%0d at time=%0t",
                             yout, expected_d2, $time);
                    error_count = error_count + 1;
                end else begin
                    $display("PASS: checked_sample=%0d yout=%0d",
                             checked_count, yout);
                end
            end

            // Advance expected-result pipeline
            expected_d2 = expected_d1;
            valid_d2    = valid_d1;
            expected_d1 = expected_now;
            valid_d1    = 1'b1;

            // Advance reference input delay line
            ref_x3 = ref_x2;
            ref_x2 = ref_x1;
            ref_x1 = sample;
            input_count = input_count + 1;
        end
    endtask

    // Drain pending expected results without adding them to the checked set
    task drain_one_cycle;
        begin
            @(negedge clk);
            xin = 8'sd0;

            @(posedge clk);
            #1;
            if (valid_d2) begin
                checked_count = checked_count + 1;
                if (yout !== expected_d2) begin
                    $display("FAIL: drain output=%0d expected=%0d at time=%0t",
                             yout, expected_d2, $time);
                    error_count = error_count + 1;
                end else begin
                    $display("PASS: checked_sample=%0d yout=%0d",
                             checked_count, yout);
                end
            end

            expected_d2 = expected_d1;
            valid_d2    = valid_d1;
            valid_d1    = 1'b0;
        end
    endtask

    initial begin
        $dumpfile("sim/fir_4tap_pipelined.vcd");
        $dumpvars(0, tb_fir_4tap_pipelined);

        rst           = 1'b1;
        xin           = 8'sd0;
        ref_x1        = 8'sd0;
        ref_x2        = 8'sd0;
        ref_x3        = 8'sd0;
        expected_now  = 18'sd0;
        expected_d1   = 18'sd0;
        expected_d2   = 18'sd0;
        valid_d1      = 1'b0;
        valid_d2      = 1'b0;
        error_count   = 0;
        checked_count = 0;
        input_count   = 0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        apply_sample( 8'sd1);
        apply_sample( 8'sd2);
        apply_sample( 8'sd3);
        apply_sample( 8'sd4);
        apply_sample( 8'sd5);
        apply_sample(-8'sd3);
        apply_sample( 8'sd10);
        apply_sample(-8'sd8);

        // Four zeros flush the FIR input delay line.
        apply_sample(8'sd0);
        apply_sample(8'sd0);
        apply_sample(8'sd0);
        apply_sample(8'sd0);

        // Two additional clocks drain the two-stage result latency.
        drain_one_cycle;
        drain_one_cycle;

        if ((error_count == 0) && (checked_count == input_count))
            $display("\nTEST PASSED: all %0d pipelined FIR results matched.\n",
                     checked_count);
        else
            $display("\nTEST FAILED: errors=%0d checked=%0d inputs=%0d.\n",
                     error_count, checked_count, input_count);

        #10;
        $finish;
    end

endmodule