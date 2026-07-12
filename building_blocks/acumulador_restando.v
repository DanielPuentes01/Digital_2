module acumulador_restando #(
    parameter REG_WIDTH = 2,
    parameter LESS_VALUE = 1
) (
    input clk,
    input rst,
    input [REG_WIDTH-1:0] initial_value,
    input less,
    output reg out_K
);

  reg [REG_WIDTH-1:0] N;

  always @(negedge clk) begin
    if (rst) N = initial_value;
    if (less) N = N - LESS_VALUE; else N = N;
  end
  assign out_K = (N == 0);
endmodule
