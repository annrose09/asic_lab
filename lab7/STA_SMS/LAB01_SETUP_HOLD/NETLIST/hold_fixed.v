module hold_fixed_top (input clk, input din, output qout);
  // Hold fix: 1 x BUF_X1 (0.50 ns) inserted -> 0.70 ns data path
  wire n0, nend;
  DFFPOS_X1 U_LAUNCH  (.CLK(clk), .D(din), .Q(n0));
  BUF_X1 u_d0 (.A(n0), .Y(nend));
  DFFPOS_X1 U_CAPTURE (.CLK(clk), .D(nend), .Q(qout));
endmodule
