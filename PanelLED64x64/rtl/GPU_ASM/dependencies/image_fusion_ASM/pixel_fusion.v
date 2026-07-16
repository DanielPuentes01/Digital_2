module pixel_fusion (
    input  [7:0] image_pixel,
    input  [7:0] overlay_pixel,
    output [7:0] fusion_pixel
);
  wire select;
  assign select = |overlay_pixel; //Realiza un or con los bits de el pixel para saber si todos son cero
  multiplexor2x1 #(.IN_WIDTH(8)) pixel_choose (
      .IN1    (overlay_pixel),//Si el pixel no es cero
      .IN0    (image_pixel),//Si el pixel es cero
      .SELECT (select),
      .MUX_OUT(fusion_pixel)
  );

endmodule
