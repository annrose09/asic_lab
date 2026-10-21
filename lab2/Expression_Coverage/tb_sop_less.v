module tb_sop_less;
    reg A, B, C, D;
    wire Y;

    sop_4bit dut(
        .A(A), .B(B), .C(C), .D(D),
        .Y(Y)
    );

    initial begin
        // Missing condition evaluation for individual OR/AND sub-expressions
        A = 0; B = 0; C = 0; D = 0; #10;
        A = 1; B = 1; C = 1; D = 1; #10;
        $finish;
    end
endmodule
