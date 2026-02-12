module acumulador_restando #(
    parameter REG_WIDTH = 2,
    parameter LESS_VALUE = 1
) (
    clk,
    rst,
    initial_value,
    less,
    out_K
);
  input rst;
  input clk;
  input less;
  input [REG_WIDTH-1:0] initial_value;
  output out_K;
  reg [REG_WIDTH-1:0] N;

  always @(posedge clk) begin
    if (rst) N = initial_value;
    if (less) N = N - LESS_VALUE; else N = N;
  end
  assign out_K = (N == 0);
endmodule
