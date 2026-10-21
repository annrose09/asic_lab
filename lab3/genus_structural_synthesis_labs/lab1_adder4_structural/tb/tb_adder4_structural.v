`timescale 1ns/1ps
module tb_adder4_structural;
    reg  [3:0] a;
    reg  [3:0] b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;
    integer    i;
    integer    errors;
    reg  [4:0] expected;

    adder4_structural dut (
        .a(a), .b(b), .cin(cin), .sum(sum), .cout(cout)
    );

    task apply_and_check;
        input [3:0] ta;
        input [3:0] tb;
        input       tcin;
        begin
            a = ta;
            b = tb;
            cin = tcin;
            #10;
            expected = ta + tb + tcin;
            if ({cout, sum} !== expected) begin
                $display("FAIL: a=%h b=%h cin=%b got=%h expected=%h",
                         a, b, cin, {cout,sum}, expected);
                errors = errors + 1;
            end else begin
                $display("PASS: a=%h b=%h cin=%b result=%h",
                         a, b, cin, {cout,sum});
            end
        end
    endtask

    initial begin
        $dumpfile("adder4.vcd");
        $dumpvars(0, tb_adder4_structural);
        errors = 0;
        a = 0; b = 0; cin = 0;

        apply_and_check(4'h0, 4'h0, 1'b0);
        apply_and_check(4'h3, 4'h5, 1'b0);
        apply_and_check(4'h7, 4'h8, 1'b1);
        apply_and_check(4'hF, 4'h1, 1'b0);
        apply_and_check(4'hF, 4'hF, 1'b1);

        for (i = 0; i < 20; i = i + 1)
            apply_and_check($random, $random, $random);

        if (errors == 0)
            $display("ADDER TEST PASSED");
        else
            $display("ADDER TEST FAILED: %0d errors", errors);
        #10 $finish;
    end
endmodule
