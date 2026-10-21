module alu_bad(input [3:0] a,b,input [1:0] op,output reg [3:0] y);
reg unused; reg [7:0] tmp;
always @(op) begin
 if(1'b0) y=0;
 case(op)
 2'b00:y=a+b;
 2'b01:y=a-b;
 endcase
end
always @(*) if(1) tmp=y;
endmodule
