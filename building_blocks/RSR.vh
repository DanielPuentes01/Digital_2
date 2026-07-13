module RSR #(
  parameter WIDTH = 8,
  parameter RST_VALUE = 0,
  parameter PARALLEL_INPUT = 1,
  parameter PARALLEL_OUTPUT = 1,
  parameter SHIFT_AMOUNT = 1
) (
  input clk,
  input rst,
  input [(WIDTH-1)*PARALLEL_INPUT:0] in_DATA,
  input in_SHIFT,
  input in_LOAD,
  output [(WIDTH-1)*PARALLEL_OUTPUT:0] out_DATA
);
  reg [WIDTH-1:0] reg_STORED;

  generate
    if (PARALLEL_OUTPUT) assign out_DATA = reg_STORED;
    else assign out_DATA = reg_STORED[WIDTH-1];
  endgenerate

  always @(negedge clk ) begin
    if (rst) reg_STORED = RST_VALUE;
    else if (in_SHIFT) reg_STORED = reg_STORED >> SHIFT_AMOUNT;
    else if (PARALLEL_INPUT & in_LOAD) reg_STORED = in_DATA;
    else if (!PARALLEL_INPUT & in_LOAD) reg_STORED[0] = in_DATA;
    else reg_STORED = reg_STORED;
  end

endmodule
