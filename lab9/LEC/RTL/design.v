// ------------------------------------------------------------------
// GOLDEN RTL  (used for synthesis PASS case and as LEC golden design)
// sel = 1 : y <= (a + b) XOR c
// sel = 0 : y <= (a - b) + c
// Registered 9-bit output, active-low asynchronous reset.
//
// NOTE: the module is named "design_top", not "design".
// "design" is a reserved keyword in Verilog-2001 (config blocks),
// so "module design" is rejected by Genus / Conformal parsers.
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
  wire [8:0] next_y     = sel ? (add_result ^ {1'b0, c})
                              : (sub_result + {1'b0, c});

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      y <= 9'b0;
    else
      y <= next_y;
  end

endmodule
