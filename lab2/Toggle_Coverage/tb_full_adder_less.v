module tb_full_adder_less;
    reg a, b, cin;
    wire sum, cout;

    full_adder dut(
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        // Drives only static values; fails to toggle signals low-to-high-to-low
        a = 0; b = 0; cin = 0; #10;
        a = 1; b = 1; cin = 1; #10;
        $finish;
    end
endmodule
