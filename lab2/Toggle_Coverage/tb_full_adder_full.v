module tb_full_adder_full;
    reg a, b, cin;
    wire sum, cout;
    integer i;

    full_adder dut(
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        // Cycles through all 8 binary combinations (000 to 111)
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i[2:0];
            #10;
        end
        // Drives inputs back to 000 to force high-to-low transitions (1 -> 0)
        {a, b, cin} = 3'b000;
        #10;
        $finish;
    end
endmodule
