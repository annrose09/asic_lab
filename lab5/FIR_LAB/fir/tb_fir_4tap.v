`timescale 1ns/1ps

module tb_fir_4tap;

    reg clk;
    reg rst;
    reg signed [7:0] xin;
    wire signed [17:0] yout;

    integer error_count;
    integer sample_count;

    reg signed [7:0] ref_x1, ref_x2, ref_x3;
    reg signed [17:0] expected;

    fir_4tap dut (
        .clk  (clk),
        .rst  (rst),
        .xin  (xin),
        .yout (yout)
    );

    // 100 MHz clock: 10 ns period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Apply one sample and verify the registered result
    task apply_sample;
        input signed [7:0] sample;
        begin
            @(negedge clk);
            xin = sample;

            expected = (sample * 4) + (ref_x1 * 3)
                     - ref_x2 - (ref_x3 * 2);

            @(posedge clk);
            #1;
            sample_count = sample_count + 1;

            if (yout !== expected) begin
                $display("FAIL: sample=%0d xin=%0d expected=%0d yout=%0d",
                         sample_count, sample, expected, yout);
                error_count = error_count + 1;
            end else begin
                $display("PASS: sample=%0d xin=%0d yout=%0d",
                         sample_count, sample, yout);
            end

            ref_x3 = ref_x2;
            ref_x2 = ref_x1;
            ref_x1 = sample;
        end
    endtask

    initial begin
        $dumpfile("fir_4tap.vcd");
        $dumpvars(0, tb_fir_4tap);

        rst          = 1'b1;
        xin          = 8'sd0;
        ref_x1       = 8'sd0;
        ref_x2       = 8'sd0;
        ref_x3       = 8'sd0;
        expected     = 18'sd0;
        error_count  = 0;
        sample_count = 0;

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

        // Flush the delay line
        apply_sample(8'sd0);
        apply_sample(8'sd0);
        apply_sample(8'sd0);
        apply_sample(8'sd0);

        if (error_count == 0)
            $display("\nTEST PASSED: all %0d samples matched.\n", sample_count);
        else
            $display("\nTEST FAILED: %0d mismatches detected.\n", error_count);

        #10;
        $finish;
    end

endmodule
