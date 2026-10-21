module fir_4tap_shared_mult (
    input  wire                    clk,
    input  wire                    rst,
    input  wire                    sample_valid,
    output wire                    sample_ready,
    input  wire signed [7:0]       xin,
    output reg                     yout_valid,
    output reg signed [17:0]       yout
);

    // Coefficients: y[n] = 4x[n] + 3x[n-1] - x[n-2] - 2x[n-3]
    localparam signed [7:0] H0 =  8'sd4;
    localparam signed [7:0] H1 =  8'sd3;
    localparam signed [7:0] H2 = -8'sd1;
    localparam signed [7:0] H3 = -8'sd2;

    // Input sample delay line
    reg signed [7:0] x1, x2, x3;

    // Snapshot registers hold one complete FIR input window while busy
    reg signed [7:0] s0, s1, s2, s3;

    reg signed [17:0] accumulator;
    reg [2:0] state;

    localparam IDLE = 3'd0;
    localparam MAC0 = 3'd1;
    localparam MAC1 = 3'd2;
    localparam MAC2 = 3'd3;
    localparam MAC3 = 3'd4;
    localparam DONE = 3'd5;

    // One shared multiplier
    reg  signed [7:0] mult_a;
    reg  signed [7:0] mult_b;
    wire signed [15:0] mult_result;
    assign mult_result = mult_a * mult_b;

    assign sample_ready = (state == IDLE);

    // Multiplexer/control logic feeding the shared multiplier
    always @(*) begin
        mult_a = 8'sd0;
        mult_b = 8'sd0;
        case (state)
            MAC0: begin mult_a = s0; mult_b = H0; end
            MAC1: begin mult_a = s1; mult_b = H1; end
            MAC2: begin mult_a = s2; mult_b = H2; end
            MAC3: begin mult_a = s3; mult_b = H3; end
            default: begin mult_a = 8'sd0; mult_b = 8'sd0; end
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x1          <= 8'sd0;
            x2          <= 8'sd0;
            x3          <= 8'sd0;
            s0          <= 8'sd0;
            s1          <= 8'sd0;
            s2          <= 8'sd0;
            s3          <= 8'sd0;
            accumulator <= 18'sd0;
            yout         <= 18'sd0;
            yout_valid   <= 1'b0;
            state        <= IDLE;
        end else begin
            yout_valid <= 1'b0;

            case (state)
                IDLE: begin
                    accumulator <= 18'sd0;
                    if (sample_valid) begin
                        // Capture the FIR window before updating the delay line
                        s0 <= xin;
                        s1 <= x1;
                        s2 <= x2;
                        s3 <= x3;

                        // Shift in the newly accepted input sample
                        x3 <= x2;
                        x2 <= x1;
                        x1 <= xin;

                        state <= MAC0;
                    end
                end

                MAC0: begin
                    accumulator <= {{2{mult_result[15]}}, mult_result};
                    state <= MAC1;
                end

                MAC1: begin
                    accumulator <= accumulator + {{2{mult_result[15]}}, mult_result};
                    state <= MAC2;
                end

                MAC2: begin
                    accumulator <= accumulator + {{2{mult_result[15]}}, mult_result};
                    state <= MAC3;
                end

                MAC3: begin
                    yout <= accumulator + {{2{mult_result[15]}}, mult_result};
                    state <= DONE;
                end

                DONE: begin
                    yout_valid <= 1'b1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule