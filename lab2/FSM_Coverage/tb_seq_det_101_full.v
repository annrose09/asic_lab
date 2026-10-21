module tb_seq_det_101_full;
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

        // Stream exercises all states and transition arcs:
        // S_RESET -> S_RESET (in=0)
        // S_RESET -> S_1     (in=1)
        // S_1     -> S_1     (in=1)
        // S_1     -> S_10    (in=0)
        // S_10    -> S_RESET (in=0)
        // S_10    -> S_101   (in=1)
        // S_101   -> S_1     (in=1, overlapping)
        // S_101   -> S_10    (in=0, overlapping)

        in_bit = 0; #10; // S_RESET stay
        in_bit = 1; #10; // S_RESET -> S_1
        in_bit = 1; #10; // S_1 stay
        in_bit = 0; #10; // S_1 -> S_10
        in_bit = 0; #10; // S_10 -> S_RESET
        in_bit = 1; #10; // S_RESET -> S_1
        in_bit = 0; #10; // S_1 -> S_10
        in_bit = 1; #10; // S_10 -> S_101 (Found 101)
        in_bit = 1; #10; // S_101 -> S_1 (Overlap with 1)
        in_bit = 0; #10; // S_1 -> S_10
        in_bit = 1; #10; // S_10 -> S_101
        in_bit = 0; #10; // S_101 -> S_10 (Overlap with 0)

        // Asynchronous reset mid-stream to hit reset transition branch
        rst = 1; #10;
        rst = 0; #10;

        $finish;
    end
endmodule
