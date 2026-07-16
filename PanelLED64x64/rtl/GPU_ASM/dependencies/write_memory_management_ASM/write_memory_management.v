module write_memory_management (
    input clk,
    input in_write,
    input in_image_or_overlay,
    input [7:0] in_px_data,
    input [11:0] in_addr,
    input in_rst,
    output reg out_synced_write_image,
    output reg out_synced_write_overlay,
    output reg [7:0] out_synced_px_data,
    output reg [11:0] out_synced_addr,
    output reg out_synced_rst
);
  always @(negedge clk) begin
    out_synced_write_image = in_write & ~in_image_or_overlay;
    out_synced_write_overlay = in_write & in_image_or_overlay;
    out_synced_addr = in_addr;
    out_synced_px_data = in_px_data;
    out_synced_rst = in_rst;
  end
endmodule
