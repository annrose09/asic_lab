module controller_fsm (
    input      i_clk,
    input      i_rst_n,
    input      i_start,
    output reg o_load_en,
    output reg o_exec_en,
    output reg o_done
);

    localparam [1:0] IDLE    = 2'b00;
    localparam [1:0] LOAD    = 2'b01;
    localparam [1:0] EXECUTE = 2'b10;

    reg [1:0] state_q, state_d;

    always @(posedge i_clk or negedge i_rst_n) begin : state_reg_proc
        if (!i_rst_n) begin
            state_q <= IDLE;
        end else begin
            state_q <= state_d;
        end
    end

    always @(*) begin : next_state_proc
        case (state_q)
            IDLE: begin
                if (i_start) begin
                    state_d = LOAD;
                end else begin
                    state_d = IDLE;
                end
            end
            LOAD: begin
                state_d = EXECUTE;
            end
            EXECUTE: begin
                state_d = IDLE;
            end
            default: begin
                state_d = IDLE;
            end
        endcase
    end

    always @(*) begin : output_proc
        o_load_en = 1'b0;
        o_exec_en = 1'b0;
        o_done    = 1'b0;

        case (state_q)
            LOAD: begin
                o_load_en = 1'b1;
            end
            EXECUTE: begin
                o_exec_en = 1'b1;
                o_done    = 1'b1;
            end
            default: begin
            end
        endcase
    end

endmodule
