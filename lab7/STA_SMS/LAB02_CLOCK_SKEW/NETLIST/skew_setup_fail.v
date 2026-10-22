module skew_setup_fail_top (input clk, input din, output qout);
  // Negative skew: LAUNCH clock delayed by DLY_X1 (1.00 ns), capture clock direct.
  // Data path: CLK->Q 0.20 + 8 x BUF_X1 = 4.20 ns
  wire launch_clk, n0, n1, n2, n3, n4, n5, n6, n7, nend;
  DLY_X1 U_LCLK_DLY0 (.A(clk), .Y(launch_clk));
  DFFPOS_X1 U_LAUNCH  (.CLK(launch_clk), .D(din), .Q(n0));
  BUF_X1 u_d0 (.A(n0), .Y(n1));
  BUF_X1 u_d1 (.A(n1), .Y(n2));
  BUF_X1 u_d2 (.A(n2), .Y(n3));
  BUF_X1 u_d3 (.A(n3), .Y(n4));
  BUF_X1 u_d4 (.A(n4), .Y(n5));
  BUF_X1 u_d5 (.A(n5), .Y(n6));
  BUF_X1 u_d6 (.A(n6), .Y(n7));
  BUF_X1 u_d7 (.A(n7), .Y(nend));
  DFFPOS_X1 U_CAPTURE (.CLK(clk), .D(nend), .Q(qout));
endmodule
