module COMMAND_DECODER (
    input clk,
    input rst,
    input in_write,
    input [7:0] in_px_data,
    input [5:0] in_column,
    input [5:0] in_row,
    input in_image_palette,
    input in_image_overlay,
    output reg out_write,
    output reg [11:0] out_addr,
    output reg [7:0] out_px_data,
    output reg out_image_or_overlay,
    output reg out_image_select,
    output reg out_rst
);
  always @(posedge clk) begin
    if (rst) begin
      out_write = 0;
      out_addr = 0;
      out_px_data = 0;
      out_image_or_overlay = 0;
      out_image_select = 0;
      out_rst = 1;
    end else begin
      out_image_select = in_image_palette;
      out_write = in_write & (~in_image_palette | in_image_overlay);
      out_addr = {in_row, in_column};
      out_px_data = in_px_data;
      out_image_or_overlay = in_image_overlay;
      out_rst = 0;
    end
  end
endmodule
