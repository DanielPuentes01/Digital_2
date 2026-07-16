module image_fusion (
    input  [511:0] image_data,
    input  [511:0] overlay_data,
    output [511:0] fusion_data
);
  genvar i;
  generate
    for (i = 0; i < 64; i = i + 1) begin : gen_pixels_fusion
      pixel_fusion pf0 (
          .image_pixel  (image_data[(i+1)*8-1:i*8]),
          .overlay_pixel(overlay_data[(i+1)*8-1:i*8]),
          .fusion_pixel (fusion_data[(i+1)*8-1:i*8])
      );
    end
  endgenerate
endmodule
