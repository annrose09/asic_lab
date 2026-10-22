module tb_clk_high;

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

// HIGH CLOCK ACTIVITY: 200 MHz -> period = 5 ns.
initial begin
    clk = 1'b0;
    forever #2.5 clk = ~clk;
end

initial begin
    $dumpfile("clk_high.vcd");
    $dumpvars(0,tb_clk_high);

    rst_n = 1'b0;
    a = 16'h1234;
    b = 16'h0021;
    c = 16'h0011;

    #20 rst_n = 1'b1;

    // Keep data nearly constant so this experiment mainly changes clock activity.
    repeat(400) begin
        #5;
        if (($time % 500) == 0) begin
            a = a + 16'h0001;
            b = b + 16'h0001;
            c = c + 16'h0001;
        end
    end

    #20 $finish;
end
endmodule
