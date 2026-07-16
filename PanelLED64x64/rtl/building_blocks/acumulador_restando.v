module acumulador_restando #(
    parameter REG_WIDTH  = 2,
    parameter RST_VALUE  = 0,
    parameter LESS_VALUE = 1,
    parameter POS_EDGE   = 0
) (
    input clk,
    input rst,
    input less,
    output out_K
);
  reg [REG_WIDTH-1:0] N;
  generate
    if (POS_EDGE) begin : gen_POS
      always @(posedge clk) begin
        if (rst) N = RST_VALUE;
        if (less) N = N - LESS_VALUE;
        else N = N;
      end
    end else begin : gen_NEG
      always @(negedge clk) begin
        if (rst) N = RST_VALUE;
        if (less) N = N - LESS_VALUE;
        else N = N;
      end
    end
  endgenerate

  assign out_K = N == 0;
endmodule
