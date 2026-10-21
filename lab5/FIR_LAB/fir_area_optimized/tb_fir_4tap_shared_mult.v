`timescale 1ns/1ps

module tb_fir_4tap_shared_mult;
    reg clk;
    reg rst;
    reg sample_valid;
    reg signed [7:0] xin;
    wire sample_ready;
    wire yout_valid;
    wire signed [17:0] yout;

    integer errors;
    integer i;
    reg signed [7:0] model_x1, model_x2, model_x3;
    reg signed [17:0] expected;
    reg signed [7:0] stimulus [0:9];

    fir_4tap_shared_mult dut (
        .clk(clk),
        .rst(rst),
        .sample_valid(sample_valid),
        .sample_ready(sample_ready),
        .xin(xin),
        .yout_valid(yout_valid),
        .yout(yout)
    );

    always #5 clk = ~clk;

    task send_and_check;
        input signed [7:0] sample;
        begin
            while (!sample_ready)
                @(posedge clk);

            expected = (sample * 4) + (model_x1 * 3)
                     - model_x2 - (model_x3 * 2);

            @(negedge clk);
            xin = sample;
            sample_valid = 1'b1;
            @(negedge clk);
            sample_valid = 1'b0;

            model_x3 = model_x2;
            model_x2 = model_x1;
            model_x1 = sample;

            while (!yout_valid)
                @(posedge clk);

            #1;
            if (yout !== expected) begin
                $display("ERROR time=%0t xin=%0d expected=%0d yout=%0d",
                         $time, sample, expected, yout);
                errors = errors + 1;
            end else begin
                $display("PASS  time=%0t xin=%0d yout=%0d",
                         $time, sample, yout);
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        sample_valid = 1'b0;
        xin = 8'sd0;
        errors = 0;
        model_x1 = 0;
        model_x2 = 0;
        model_x3 = 0;

        stimulus[0] =  8'sd1;
        stimulus[1] =  8'sd2;
        stimulus[2] =  8'sd3;
        stimulus[3] =  8'sd4;
        stimulus[4] =  8'sd5;
        stimulus[5] = -8'sd2;
        stimulus[6] =  8'sd7;
        stimulus[7] = -8'sd4;
        stimulus[8] =  8'sd10;
        stimulus[9] =  8'sd0;

        repeat (3) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        for (i = 0; i < 10; i = i + 1)
            send_and_check(stimulus[i]);

        if (errors == 0)
            $display("\nTEST PASSED: all shared-multiplier FIR outputs matched.\n");
        else
            $display("\nTEST FAILED: %0d mismatches detected.\n", errors);

        #20;
        $finish;
    end

    initial begin
        $dumpfile("sim/fir_4tap_shared_mult.vcd");
        $dumpvars(0, tb_fir_4tap_shared_mult);
    end
endmodule