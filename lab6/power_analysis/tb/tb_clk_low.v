module tb_clk_low;

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

// LOW CLOCK ACTIVITY: 20 MHz -> period = 50 ns.
initial begin
    clk = 1'b0;
    forever #25 clk = ~clk;
end

initial begin
    $dumpfile("clk_low.vcd");
    $dumpvars(0,tb_clk_low);

    rst_n = 1'b0;
    a = 16'h1234;
    b = 16'h0021;
    c = 16'h0011;

    #100 rst_n = 1'b1;

    // Keep data nearly constant so this experiment mainly changes clock activity.
    repeat(40) begin
        #50;
        if (($time % 500) == 0) begin
            a = a + 16'h0001;
            b = b + 16'h0001;
            c = c + 16'h0001;
        end
    end

    #100 $finish;
end
endmodule
