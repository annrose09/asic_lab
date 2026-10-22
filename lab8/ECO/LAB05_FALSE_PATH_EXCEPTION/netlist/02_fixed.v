module false_path_top(input clk, input din, input cfg, output qout, output cfgout);
  wire d0,d1,d2,d3,d4,d5,d6,d7;
  wire c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13;
  DFFPOS_X1 U_DATA_L (.CLK(clk),.D(din),.Q(d0));
  BUF_X1 b0(.A(d0),.Y(d1)); BUF_X1 b1(.A(d1),.Y(d2)); BUF_X1 b2(.A(d2),.Y(d3));
  BUF_X1 b3(.A(d3),.Y(d4)); BUF_X1 b4(.A(d4),.Y(d5)); BUF_X1 b5(.A(d5),.Y(d6));
  DFFPOS_X1 U_DATA_C (.CLK(clk),.D(d6),.Q(qout));
  DFFPOS_X1 U_CFG_L (.CLK(clk),.D(cfg),.Q(c0));
  BUF_X1 c_0(.A(c0),.Y(c1)); BUF_X1 c_1(.A(c1),.Y(c2)); BUF_X1 c_2(.A(c2),.Y(c3));
  BUF_X1 c_3(.A(c3),.Y(c4)); BUF_X1 c_4(.A(c4),.Y(c5)); BUF_X1 c_5(.A(c5),.Y(c6));
  BUF_X1 c_6(.A(c6),.Y(c7)); BUF_X1 c_7(.A(c7),.Y(c8)); BUF_X1 c_8(.A(c8),.Y(c9));
  BUF_X1 c_9(.A(c9),.Y(c10)); BUF_X1 c_10(.A(c10),.Y(c11)); BUF_X1 c_11(.A(c11),.Y(c12));
  DFFPOS_X1 U_CFG_C (.CLK(clk),.D(c12),.Q(cfgout));
endmodule
