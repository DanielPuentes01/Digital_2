module MultipleRSR #(
    parameter RST_VALUE = {1'b1, 510'b0, 1'b1},
    parameter IN_WIDTH = 8,
    parameter SIZE = 512
) (
    input clk,
    input rst,
    input [IN_WIDTH-1:0] in_data,
    input in_LOAD,
    output reg [SIZE-1:0] out_data
);
  always @(negedge clk) begin
    if (rst) out_data = RST_VALUE;
    else if (in_LOAD) out_data = {in_data,out_data[SIZE-1:IN_WIDTH]};
  end
endmodule
