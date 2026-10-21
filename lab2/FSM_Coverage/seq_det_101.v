//----------------------------------------------------
// 101 Sequence Detector FSM (Overlapping)
//----------------------------------------------------
module seq_det_101(
    input clk,
    input rst,
    input in_bit,
    output seq_found
);
    parameter S_RESET = 2'd0,
              S_1     = 2'd1,
              S_10    = 2'd2,
              S_101   = 2'd3;

    reg [1:0] state, next_state;

    // State memory
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S_RESET;
        else
            state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        case (state)
            S_RESET: next_state = in_bit ? S_1   : S_RESET;
            S_1:     next_state = in_bit ? S_1   : S_10;
            S_10:    next_state = in_bit ? S_101 : S_RESET;
            S_101:   next_state = in_bit ? S_1   : S_10;
            default: next_state = S_RESET;
        endcase
    end

    // Output assignment
    assign seq_found = (state == S_101);
endmodule
