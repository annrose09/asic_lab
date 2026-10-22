module hold_physical(input clk,input din,output qout);
 wire n0,n1,n2;
 DFFPOS_X1 U_LAUNCH(.CLK(clk),.D(din),.Q(n0));
 BUF_X1 b0(.A(n0),.Y(n1));
 BUF_X1 b1(.A(n1),.Y(n2));
 DFFPOS_X1 U_CAPTURE(.CLK(clk),.D(n2),.Q(qout));
endmodule
