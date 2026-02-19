module rsr(
  clk,
  rst,
  init,
  data_in,
  sft,
  data_out
);

  input clk;
  input rst;
  input init;
  input [7:0] data_in;
  input sft;

  reg [7:0] data;

  output reg data_out;

  always @(negedge clk) begin
    if (rst) begin
      data = 0;
      data_out = 1;
    end else if (init) begin
      data = data_in;
      data_out = data[0];
    end else if (sft) begin
      data = data >> 1;
      data_out = data[0];
    end
  end

endmodule