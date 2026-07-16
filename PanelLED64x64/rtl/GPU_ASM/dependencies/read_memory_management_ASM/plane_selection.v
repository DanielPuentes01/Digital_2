module plane_selection (
    input  [  1:0] in_selection,
    input  [511:0] in_row_data,
    output [ 63:0] out_red_channel,
    output [ 63:0] out_green_channel,
    output [ 63:0] out_blue_channel
);

  genvar i;
  generate
    for (i = 0; i < 64; i = i + 1) begin : gen_px_plane_selection
      pixel_plane_selection u_pps (
          .px_data  (in_row_data[(i+1)*8-1:i*8]),
          .selection(in_selection),
          .R        (out_red_channel[i]),
          .G        (out_green_channel[i]),
          .B        (out_blue_channel[i])
      );

    end
  endgenerate

endmodule
