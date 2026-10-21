module mux_bad(input [3:0] a,b,input sel,output reg [3:0] y);
reg unused; reg [7:0] temp;
always @(sel) begin
 if(1'b0) y=0;
 if(sel) y=a;
end
always @(*) begin
 if(1) temp=a;
end
endmodule
