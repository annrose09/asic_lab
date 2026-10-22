module hold_fail_top (input clk, input din, output qout);
  // Data path: CLK->Q 0.20 ns only (direct FF-to-FF connection)
  wire n0;
  DFFPOS_X1 U_LAUNCH  (.CLK(clk), .D(din), .Q(n0));
  DFFPOS_X1 U_CAPTURE (.CLK(clk), .D(n0), .Q(qout));
endmodule
