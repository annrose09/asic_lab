module tb_sop_full;
    reg A, B, C, D;
    wire Y;

    // Instantiate Top Module
    sop_4bit dut (
        .A(A),
        .B(B),
        .C(C),
        .D(D),
        .Y(Y)
    );

    // Task to apply vectors and delay
    task apply_vector(input a_in, input b_in, input c_in, input d_in);
        begin
            A = a_in; B = b_in; C = c_in; D = d_in;
            #10;
        end
    endtask

    initial begin
        // =========================================================================
        // PHASE 1: Targeted MC/DC Vectors for Expression Coverage
        // Expressions:
        // Y = (A & B) | (C & D)
        // =========================================================================

        // --- SOP Coverage Vectors ---
        // 1. Both terms FALSE: (0 & 0) | (0 & 0) = 0
        apply_vector(0, 0, 0, 0);

        // 2. Test A's effect on (A & B): Hold B=1, C=0, D=0; Toggle A
        apply_vector(1, 1, 0, 0); // Y = 1
        apply_vector(0, 1, 0, 0); // Y = 0 (Proves A affects SOP)

        // 3. Test B's effect on (A & B): Hold A=1, C=0, D=0; Toggle B
        apply_vector(1, 0, 0, 0); // Y = 0 (Proves B affects SOP)

        // 4. Test C's effect on (C & D): Hold D=1, A=0, B=0; Toggle C
        apply_vector(0, 0, 1, 1); // Y = 1
        apply_vector(0, 0, 0, 1); // Y = 0 (Proves C affects SOP)

        // 5. Test D's effect on (C & D): Hold C=1, A=0, B=0; Toggle D
        apply_vector(0, 0, 1, 0); // Y = 0 (Proves D affects SOP)

        // Return to zero baseline
        apply_vector(0, 0, 0, 0);

        $finish;
    end
endmodule
