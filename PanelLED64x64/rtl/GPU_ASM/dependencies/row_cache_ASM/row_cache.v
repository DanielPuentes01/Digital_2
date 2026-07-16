module row_cache (
    input clk,
    input [511:0] in_data,
    input in_load,
    output reg [511:0] out_data
);
  always @(posedge clk) begin
     out_data = in_load ? in_data : out_data;
  end
endmodule
