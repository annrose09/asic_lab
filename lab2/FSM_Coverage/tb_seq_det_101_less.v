module tb_seq_det_101_less;
    reg clk, rst, in_bit;
    wire seq_found;

    seq_det_101 dut(
        .clk(clk),
        .rst(rst),
        .in_bit(in_bit),
        .seq_found(seq_found)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; in_bit = 0; #10;
        rst = 0;
        // Incomplete stimulus: FSM gets stuck in S_RESET; S1, S10, S101 never reached
        in_bit = 0; #20;
        $finish;
    end
endmodule
