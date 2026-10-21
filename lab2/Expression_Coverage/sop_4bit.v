//----------------------------------------------------
// 4-Bit Expression Module
//----------------------------------------------------
module sop_4bit(
    input A,
    input B,
    input C,
    input D,
    output reg Y
);

    always @(*) begin
        if ((A && B) || (C && D))
            Y = 1;
        else
            Y = 0;
    end

endmodule
