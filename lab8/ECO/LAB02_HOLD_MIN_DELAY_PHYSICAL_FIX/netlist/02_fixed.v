module hold_physical(input clk,input din,output qout);
 wire n0,n1,n2,n3,n4;
 DFFPOS_X1 U_LAUNCH(.CLK(clk),.D(din),.Q(n0));
 BUF_X1 b0(.A(n0),.Y(n1));
 BUF_X1 b1(.A(n1),.Y(n2));
 // Physical hold repair: two delay cells inserted.
 DLY_X1 HOLD_DLY0(.A(n2),.Y(n3));
 DLY_X1 HOLD_DLY1(.A(n3),.Y(n4));
 DFFPOS_X1 U_CAPTURE(.CLK(clk),.D(n4),.Q(qout));
endmodule
