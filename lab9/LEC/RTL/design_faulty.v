// ------------------------------------------------------------------
// FAULTY RTL  (used only to create the LEC FAIL case)
// Identical to design.v EXCEPT one intentional bug:
//   sel = 1 path uses OR (|) instead of XOR (^).
// Same module name as the golden RTL so Conformal maps the two
// designs key-point by key-point (y_reg[0..8]).
// ------------------------------------------------------------------
module design_top (
    input            clk,
    input            rst_n,
    input            sel,
    input      [7:0] a,
    input      [7:0] b,
    input      [7:0] c,
    output reg [8:0] y
);

  wire [8:0] add_result = {1'b0, a} + {1'b0, b};
  wire [8:0] sub_result = {1'b0, a} - {1'b0, b};
  // ---- INTENTIONAL BUG: '|' replaces '^' on the sel = 1 path ----
  wire [8:0] next_y     = sel ? (add_result | {1'b0, c})
                              : (sub_result + {1'b0, c});

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      y <= 9'b0;
    else
      y <= next_y;
  end

endmodule
