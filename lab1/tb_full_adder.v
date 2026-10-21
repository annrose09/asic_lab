module tb_full_adder;

    reg  a, b, cin;
    wire sum, cout;

    full_adder uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        $display("--- 1-BIT FULL ADDER TEST ---");
        $display("Time | A B Cin | Sum Cout");

        {a, b, cin} = 3'b000;

        repeat (8) begin
            #10;
            $display("%4t | %b %b  %b  |  %b    %b", $time, a, b, cin, sum, cout);
            {a, b, cin} = {a, b, cin} + 1'b1;
        end

        $finish;
    end

    // Dump EXACTLY the 5 required signal waveforms
    initial begin
        $dumpfile("fa_waves.vcd");
        $dumpvars(0, a, b, cin, sum, cout);
    end

endmodule
