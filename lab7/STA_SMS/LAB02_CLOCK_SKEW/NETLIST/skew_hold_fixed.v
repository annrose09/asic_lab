module skew_hold_fixed_top (input clk, input din, output qout);
  // Same +1.00 ns capture-clock delay as the FAIL case.
  // Hold fix: 2 x BUF_X1 (1.00 ns) added in the data path -> 1.20 ns
  wire capture_clk, n0, n1, nend;
  DLY_X1 U_CCLK_DLY0 (.A(clk), .Y(capture_clk));
  DFFPOS_X1 U_LAUNCH  (.CLK(clk), .D(din), .Q(n0));
  BUF_X1 u_d0 (.A(n0), .Y(n1));
  BUF_X1 u_d1 (.A(n1), .Y(nend));
  DFFPOS_X1 U_CAPTURE (.CLK(capture_clk), .D(nend), .Q(qout));
endmodule
