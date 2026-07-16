module DEMO_GPU (
    input clk,
    input rstn,
    output wire LED,
    output [2:0] wire_to_screen_RGB0,
    output [2:0] wire_to_screen_RGB1,
    output wire_to_screen_CLK,
    output [4:0] wire_to_screen_ABCDE,
    output wire_to_screen_LATCH,
    output wire_to_screen_nOE
);
  parameter CENTER_X = 6'd15;
  parameter CENTER_Y = 6'd0;
  reg [23:0] frame_timer;
  reg frame;
  reg [1:0] state;
  assign LED = frame;
  always @(negedge clk) begin
    if (!rstn) begin
      frame_timer = 0;
      frame = 0;
      state = 0;
    end else if (frame_timer[23]) begin
      if (state == 2'b11) begin
        frame = ~frame;
        state = 0;
        frame_timer = 0;
      end else state = state + 1;
    end else frame_timer = frame_timer + 1;
  end

  always @(*) begin
    to_gpu_column = CENTER_X + state[0];
    to_gpu_row = CENTER_Y + state[1];
    to_gpu_write = frame_timer[23];
    to_gpu_px_data = frame ? 8'h00 : 8'h01;
  end

  reg to_gpu_write;
  reg [7:0] to_gpu_px_data;
  reg [5:0] to_gpu_column;
  reg [5:0] to_gpu_row;

  GPU u_GPU (
      .clk            (clk),
      .rstn           (rstn),
      .write          (to_gpu_write),
      .px_data        (to_gpu_px_data),
      .column         (to_gpu_column),
      .row            (to_gpu_row),
      .image_palette  (frame),
      .image_overlay  (1'b1),
      .to_screen_RGB0 (wire_to_screen_RGB0),
      .to_screen_RGB1 (wire_to_screen_RGB1),
      .to_screen_CLK  (wire_to_screen_CLK),
      .to_screen_ABCDE(wire_to_screen_ABCDE),
      .to_screen_LATCH(wire_to_screen_LATCH),
      .to_screen_nOE  (wire_to_screen_nOE)
  );


endmodule
