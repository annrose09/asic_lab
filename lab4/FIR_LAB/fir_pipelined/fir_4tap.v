module fir_4tap (
    input  wire                    clk,
    input  wire                    rst,
    input  wire signed [7:0]       xin,
    output reg  signed [17:0]      yout
);

    // Delay-line registers: x[n-1], x[n-2], x[n-3]
    reg signed [7:0] x1, x2, x3;

    // Fixed FIR coefficients: H = [4, 3, -1, -2]
    localparam signed [7:0] H0 =  8'sd4;
    localparam signed [7:0] H1 =  8'sd3;
    localparam signed [7:0] H2 = -8'sd1;
    localparam signed [7:0] H3 = -8'sd2;

    // Direct multiplication results
    wire signed [15:0] m0 = xin * H0;
    wire signed [15:0] m1 = x1  * H1;
    wire signed [15:0] m2 = x2  * H2;
    wire signed [15:0] m3 = x3  * H3;

    // Delay line and registered FIR output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x1   <= 8'sd0;
            x2   <= 8'sd0;
            x3   <= 8'sd0;
            yout <= 18'sd0;
        end else begin
            // y[n] = 4x[n] + 3x[n-1] - x[n-2] - 2x[n-3]
            yout <= m0 + m1 + m2 + m3;

            x3 <= x2;
            x2 <= x1;
            x1 <= xin;
        end
    end

endmodule
