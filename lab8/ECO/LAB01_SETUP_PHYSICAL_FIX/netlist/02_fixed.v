module setup_physical(input clk,input din,output qout);
 wire n0,n1,n2,n3,n4,n5,n6,n7,n8;
 DFFPOS_X1 U_LAUNCH(.CLK(clk),.D(din),.Q(n0));
 // Physical optimization: same topology, faster cells.
 BUF_X2 b0(.A(n0),.Y(n1)); BUF_X2 b1(.A(n1),.Y(n2));
 BUF_X2 b2(.A(n2),.Y(n3)); BUF_X2 b3(.A(n3),.Y(n4));
 BUF_X2 b4(.A(n4),.Y(n5)); BUF_X2 b5(.A(n5),.Y(n6));
 BUF_X2 b6(.A(n6),.Y(n7)); BUF_X2 b7(.A(n7),.Y(n8));
 DFFPOS_X1 U_CAPTURE(.CLK(clk),.D(n8),.Q(qout));
endmodule
