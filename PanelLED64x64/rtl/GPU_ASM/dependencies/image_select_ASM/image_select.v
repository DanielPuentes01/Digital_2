module image_select (
    input clk,
    input rst,
    input [5:0] in_ADDR,
    input in_rd,
    input in_VRAM_AVAILABLE,
    output wire [511:0] out_data,
    output wire out_VRAM_SIGNAL
);
  wire [22:0] w_TIMER_VALUE;
  assign out_VRAM_SIGNAL = VRAM0_SIGNAL | VRAM1_SIGNAL;
  wire VRAM0_SIGNAL;
  wire VRAM1_SIGNAL;
  reg  reg_frame;
  reg  reg_TIMER_PLUS;
  parameter WAITING = 0;
  parameter SWITCHING = 1;
  reg state;
  reg reg_RST;
  always @(posedge clk) begin
    if (rst) begin
      reg_RST = 1;
      reg_frame = 1;
      reg_TIMER_PLUS = 0;
      state = WAITING;
    end else
      case (state)
        WAITING: begin
          if (w_TIMER_VALUE[22]) begin
            if (in_VRAM_AVAILABLE) begin
              reg_RST = 1;
              reg_TIMER_PLUS = 0;
              reg_frame = ~reg_frame;
              state = SWITCHING;
            end else begin
              reg_RST = 0;
              reg_TIMER_PLUS = 0;
              reg_frame = reg_frame;
              state = WAITING;
            end
          end else begin
            reg_RST = 0;
            reg_TIMER_PLUS = 1;
            reg_frame = reg_frame;
            state = WAITING;
          end
        end
        SWITCHING: begin
          reg_RST = 0;
          reg_TIMER_PLUS = 1;
          reg_frame = reg_frame;
          state = WAITING;
        end
        default: begin
          reg_RST = 1;
          reg_frame = 0;
          reg_TIMER_PLUS = 0;
          state = WAITING;
        end
      endcase
  end

  multiplexor2x1 #(
      .IN_WIDTH(512)
  ) u_multiplexor2x1 (
      .IN1    (w_data_FRAME1),
      .IN0    (w_data_FRAME0),
      .SELECT (reg_frame),
      .MUX_OUT(out_data)
  );

  wire [511:0] w_data_FRAME0;
  VRAM #(
      .HEX_FILE("./test_benches/octopuss/octopuss0.hex")
  ) u_FRAME0 (
      .clk        (clk),
      .rst        (reg_RST),
      .wr         (1'b0),
      .wr_addr    (12'b0),
      .in_data    (8'b0),
      .rd         (in_rd & ~reg_frame),
      .rd_addr    (in_ADDR),
      .out_data   (w_data_FRAME0),
      .out_charged(VRAM0_SIGNAL)
  );
  wire [511:0] w_data_FRAME1;
  VRAM #(
      .HEX_FILE("./test_benches/octopuss/octopuss1.hex")
  ) u_FRAME1 (
      .clk        (clk),
      .rst        (reg_RST),
      .wr         (1'b0),
      .wr_addr    (12'b0),
      .in_data    (8'b0),
      .rd         (in_rd & reg_frame),
      .rd_addr    (in_ADDR),
      .out_data   (w_data_FRAME1),
      .out_charged(VRAM1_SIGNAL)
  );

  acumulador #(
      .WIDTH(23)
  ) u_frame_switch_counter (
      .clk  (clk),
      .rst  (reg_RST),
      .plus (reg_TIMER_PLUS),
      .value(w_TIMER_VALUE)    //20
  );


endmodule
