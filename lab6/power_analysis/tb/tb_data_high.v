module tb_data_high;

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
    $dumpfile("data_high.vcd");
    $dumpvars(0,tb_data_high);

    rst_n = 1'b0;
    a = 16'h0001;
    b = 16'h00F0;
    c = 16'h0F0F;

    #20 rst_n = 1'b1;

    // HIGH DATA ACTIVITY:
    // operands deliberately change every cycle with many bit transitions.
    for (i=0; i<200; i=i+1) begin
        @(negedge clk);
        a <= ~a;
        b <= {b[14:0],b[15]} ^ 16'hA5A5;
        c <= c ^ 16'hFFFF;
    end

    #20 $finish;
end
endmodule
