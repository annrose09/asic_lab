module fir_4tap_pipelined (
    input  wire               clk,
    input  wire               rst,
    input  wire signed [7:0]  xin,
    output reg  signed [17:0] yout
);

    // Input sample delay line: x[n-1], x[n-2], x[n-3]
    reg signed [7:0] x1, x2, x3;

    // Fixed FIR coefficients: H = [4, 3, -1, -2]
    localparam signed [7:0] H0 =  8'sd4;
    localparam signed [7:0] H1 =  8'sd3;
    localparam signed [7:0] H2 = -8'sd1;
    localparam signed [7:0] H3 = -8'sd2;

    // Direct multiplication results
    wire signed [15:0] m0;
    wire signed [15:0] m1;
    wire signed [15:0] m2;
    wire signed [15:0] m3;

    assign m0 = xin * H0;
    assign m1 = x1  * H1;
    assign m2 = x2  * H2;
    assign m3 = x3  * H3;

    // Sign-extended products for the 18-bit adder pipeline
    wire signed [17:0] m0_ext = {{2{m0[15]}}, m0};
    wire signed [17:0] m1_ext = {{2{m1[15]}}, m1};
    wire signed [17:0] m2_ext = {{2{m2[15]}}, m2};
    wire signed [17:0] m3_ext = {{2{m3[15]}}, m3};

    // Pipeline alignment registers
    reg signed [17:0] add_stage1;
    reg signed [17:0] add_stage2;
    reg signed [17:0] m2_delay1;
    reg signed [17:0] m3_delay1;
    reg signed [17:0] m3_delay2;

    // Pipelined direct-form FIR:
    // Stage 1: (m0 + m1), while delaying m2 and m3
    // Stage 2: (m0 + m1) + m2, while delaying m3 again
    // Stage 3: (m0 + m1 + m2) + m3
    // The output corresponding to an input sample appears two clocks later.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x1         <= 8'sd0;
            x2         <= 8'sd0;
            x3         <= 8'sd0;
            add_stage1 <= 18'sd0;
            add_stage2 <= 18'sd0;
            m2_delay1  <= 18'sd0;
            m3_delay1  <= 18'sd0;
            m3_delay2  <= 18'sd0;
            yout       <= 18'sd0;
        end else begin
            // Pipeline stage 3
            yout <= add_stage2 + m3_delay2;

            // Pipeline stage 2
            add_stage2 <= add_stage1 + m2_delay1;
            m3_delay2  <= m3_delay1;

            // Pipeline stage 1
            add_stage1 <= m0_ext + m1_ext;
            m2_delay1  <= m2_ext;
            m3_delay1  <= m3_ext;

            // Update the FIR input delay line
            x3 <= x2;
            x2 <= x1;
            x1 <= xin;
        end
    end

endmodule