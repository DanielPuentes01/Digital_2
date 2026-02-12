module acumulador #(
    parameter WIDTH = 2,
    parameter RST_VALUE = 0,
    parameter PLUS_VALUE = 1,
    parameter POS_EDGE = 0
) (
    input clk,
    input rst,
    input plus,
    output [WIDTH-1:0] value
);
  reg [WIDTH-1:0] N;
  assign value = N;
  generate
    if (POS_EDGE) begin : gen_POS
      always @(posedge clk) begin
        if (rst) N = RST_VALUE;
        else if (plus) N = N + PLUS_VALUE;
        else N = N;
      end
    end else begin : gen_NEG
      always @(negedge clk) begin
        if (rst) N = RST_VALUE;
        else if (plus) N = N + PLUS_VALUE;
        else N = N;
      end
    end
  endgenerate

endmodule
