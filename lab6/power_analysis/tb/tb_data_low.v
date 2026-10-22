module tb_data_low;

reg clk;
reg rst_n;
reg [15:0] a,b,c;
wire [31:0] y;
wire [63:0] activity_regs;

activity_power_top dut(
    .clk(clk), .rst_n(rst_n),
    .a(a), .b(b), .c(c),
    .y(y), .activity_regs(activity_regs)
);

// Fixed clock for both DATA experiments: 100 MHz.
initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

integer i;
initial begin
    $dumpfile("data_low.vcd");
    $dumpvars(0,tb_data_low);

    rst_n = 1'b0;
    a = 16'h0001;
    b = 16'h0003;
    c = 16'h0007;

    #20 rst_n = 1'b1;

    // LOW DATA ACTIVITY:
    // operands change only once every 10 cycles.
    for (i=0; i<200; i=i+1) begin
        @(negedge clk);
        if ((i % 10) == 0) begin
            a <= a + 16'h0001;
            b <= b + 16'h0003;
            c <= c + 16'h0005;
        end
    end

    #20 $finish;
end
endmodule
