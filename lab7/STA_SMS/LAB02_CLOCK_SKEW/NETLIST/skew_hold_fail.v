module skew_hold_fail_top (input clk, input din, output qout);
  // Positive skew: CAPTURE clock delayed by DLY_X1 (1.00 ns).
  // Data path: direct FF-to-FF, CLK->Q 0.20 ns
  wire capture_clk, n0;
  DLY_X1 U_CCLK_DLY0 (.A(clk), .Y(capture_clk));
  DFFPOS_X1 U_LAUNCH  (.CLK(clk), .D(din), .Q(n0));
  DFFPOS_X1 U_CAPTURE (.CLK(capture_clk), .D(n0), .Q(qout));
endmodule
