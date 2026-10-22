module activity_power_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire [15:0] c,
    output reg  [31:0] y,
    output reg  [63:0] activity_regs
);

wire [31:0] mult_result;
wire [31:0] datapath_result;

assign mult_result    = a * b;
assign datapath_result = mult_result + {16'd0, c};

always @(posedge clk) begin
    if (!rst_n) begin
        y             <= 32'd0;
        activity_regs <= 64'd0;
    end else begin
        y <= datapath_result;

        // A deliberately wide sequential bank so clock activity is visible.
        activity_regs[31:0]  <= datapath_result;
        activity_regs[63:32] <= {a,b};
    end
end

endmodule
