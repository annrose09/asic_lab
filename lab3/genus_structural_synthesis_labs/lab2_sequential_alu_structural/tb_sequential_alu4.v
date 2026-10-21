`timescale 1ns/1ps
module tb_sequential_alu4;
    reg        clk;
    reg        rst;
    reg  [3:0] a;
    reg  [3:0] b;
    reg  [1:0] opcode;
    wire [3:0] result;
    wire       carry;
    integer    errors;
    reg  [4:0] expected;

    sequential_alu4_structural dut (
        .clk(clk), .rst(rst), .a(a), .b(b), .opcode(opcode),
        .result(result), .carry(carry)
    );

    always #5 clk = ~clk;

    task apply_and_check;
        input [3:0] ta;
        input [3:0] tb;
        input [1:0] top;
        begin
            @(negedge clk);
            a = ta;
            b = tb;
            opcode = top;

            case (top)
                2'b00: expected = ta + tb;
                2'b01: expected = {1'b0, ta} + {1'b0, ~tb} + 5'b00001;
                2'b10: expected = {1'b0, (ta & tb)};
                2'b11: expected = {1'b0, (ta | tb)};
            endcase

            @(posedge clk);
            #1;
            if ({carry, result} !== expected) begin
                $display("FAIL: op=%b a=%h b=%h got=%h expected=%h",
                         opcode, a, b, {carry,result}, expected);
                errors = errors + 1;
            end else begin
                $display("PASS: op=%b a=%h b=%h result=%h",
                         opcode, a, b, {carry,result});
            end
        end
    endtask

    initial begin
        $dumpfile("sequential_alu4.vcd");
        $dumpvars(0, tb_sequential_alu4);
        clk = 0;
        rst = 1;
        a = 0;
        b = 0;
        opcode = 0;
        errors = 0;

        #12 rst = 0;

        apply_and_check(4'h3, 4'h5, 2'b00);
        apply_and_check(4'hF, 4'h1, 2'b00);
        apply_and_check(4'h9, 4'h3, 2'b01);
        apply_and_check(4'h3, 4'h9, 2'b01);
        apply_and_check(4'hA, 4'hC, 2'b10);
        apply_and_check(4'hA, 4'h5, 2'b11);
        apply_and_check(4'hF, 4'hF, 2'b10);
        apply_and_check(4'h0, 4'hF, 2'b11);

        if (errors == 0)
            $display("SEQUENTIAL ALU TEST PASSED");
        else
            $display("SEQUENTIAL ALU TEST FAILED: %0d errors", errors);

        #10 $finish;
    end
endmodule
