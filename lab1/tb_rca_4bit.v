module tb_rca_4bit;

    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;

    rca_4bit uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        $display("--- 4-BIT RIPPLE CARRY ADDER TEST ---");
        $monitor("Time=%0t | A=%d B=%d Cin=%b -> Sum=%d Cout=%b", 
                  $time, a, b, cin, sum, cout);

        a = 4'd2;  b = 4'd3;  cin = 0; #10; // Sum = 5, Cout = 0
        a = 4'd7;  b = 4'd8;  cin = 0; #10; // Sum = 15, Cout = 0
        a = 4'd15; b = 4'd1;  cin = 0; #10; // Sum = 0, Cout = 1 (Overflow)
        a = 4'd9;  b = 4'd5;  cin = 1; #10; // Sum = 15, Cout = 0

        $finish;
    end

    // Dump waveforms for Xcelium/Incisive (SimVision)
    initial begin
        $dumpfile("rca_waves.vcd");
        $dumpvars(0, tb_rca_4bit);
    end

endmodule
