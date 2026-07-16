module read_memory_management (
    input clk,
    input rst,
    input in_CACHE,
    input [4:0] in_ROW,
    input [1:0] in_PLANE_SELECT,
    input in_SHIFT_PLANE,
    input [5:0] in_RGB01,
    input [511:0] in_ROW0_DATA,
    input [511:0] in_ROW1_DATA,
    input in_VRAM_DONE_READ,

    output reg out_PLANE_READY,
    output reg out_PLANE_LOAD0,
    output reg out_PLANE_LOAD1,
    output reg out_PLANE_SHIFT,
    output reg out_ROW_LOAD0,
    output reg out_ROW_LOAD1,
    output [2:0] out_RGB0,
    output [2:0] out_RGB1,
    output [63:0] out_R,
    output [63:0] out_G,
    output [63:0] out_B,
    output [5:0] out_ADDR,
    output reg out_RD
);
  reg reg_SIDE;

  assign out_ADDR = {reg_SIDE, in_ROW};

  assign out_RGB0 = in_RGB01[5:3];
  assign out_RGB1 = in_RGB01[2:0];

  wire [511:0] w_cache_row;
  multiplexor2x1 #(
      .IN_WIDTH(512)
  ) u_multiplexor2x1 (
      .IN1    (in_ROW1_DATA),
      .IN0    (in_ROW0_DATA),
      .SELECT (reg_SIDE),
      .MUX_OUT(w_cache_row)
  );

  plane_selection u_plane_selection (
      .in_selection     (in_PLANE_SELECT),
      .in_row_data      (w_cache_row),
      .out_red_channel  (out_R),
      .out_green_channel(out_G),
      .out_blue_channel (out_B)
  );

  reg [3:0] state;
  reg reg_row_cached;
  parameter START = 0;
  parameter SHIFT_P = 1;
  parameter S_LOAD0 = 2;
  parameter S_LOAD1 = 3;
  parameter DONE = 4;

  parameter S_CACHE_ROW0 = 5;
  parameter S_LOAD_ROW0 = 6;
  parameter S_CACHE_ROW1 = 7;
  parameter S_LOAD_ROW1 = 8;
  always @(negedge clk) begin
    if (rst) begin
      state = START;
      out_RD = 0;
      out_PLANE_SHIFT = 0;
      out_PLANE_LOAD0 = 0;
      out_PLANE_LOAD1 = 0;
      out_PLANE_READY = 0;
      reg_row_cached = 0;
      reg_SIDE = 0;
      out_ROW_LOAD0 = 0;
      out_ROW_LOAD1 = 0;
    end else
      case (state)
        START: begin
          if (in_SHIFT_PLANE & reg_row_cached) begin
            out_RD = 0;
            out_PLANE_SHIFT = 1;
            out_PLANE_LOAD0 = 0;
            out_PLANE_LOAD1 = 0;
            out_PLANE_READY = 0;
            reg_row_cached = reg_row_cached;
            out_ROW_LOAD0 = 0;
            out_ROW_LOAD1 = 0;
            reg_SIDE = 0;
            state = SHIFT_P;
          end else if (in_CACHE) begin
            if (reg_row_cached) begin
              out_RD = 0;
              out_PLANE_SHIFT = 0;
              out_PLANE_LOAD0 = 1;
              out_PLANE_LOAD1 = 0;
              out_PLANE_READY = 0;
              reg_row_cached = reg_row_cached;
              reg_SIDE = 0;
              out_ROW_LOAD0 = 0;
              out_ROW_LOAD1 = 0;
              state = S_LOAD0;
            end else begin
              out_RD = 1;
              out_PLANE_SHIFT = 0;
              out_PLANE_LOAD0 = 0;
              out_PLANE_LOAD1 = 0;
              out_PLANE_READY = 0;
              reg_row_cached = 0;
              reg_SIDE = 0;
              out_ROW_LOAD0 = 0;
              out_ROW_LOAD1 = 0;
              state = S_CACHE_ROW0;
            end
          end
        end
        SHIFT_P: begin
          if (in_SHIFT_PLANE) begin
            out_RD = 0;
            out_PLANE_SHIFT = 1;
            out_PLANE_LOAD0 = 0;
            out_PLANE_LOAD1 = 0;
            out_PLANE_READY = 0;
            reg_SIDE = 0;
            out_ROW_LOAD0 = 0;
            out_ROW_LOAD1 = 0;
            state = SHIFT_P;
          end else begin
            out_RD = 0;
            out_PLANE_SHIFT = 0;
            out_PLANE_LOAD0 = 0;
            out_PLANE_LOAD1 = 0;
            out_PLANE_READY = 0;
            reg_SIDE = 0;
            out_ROW_LOAD0 = 0;
            out_ROW_LOAD1 = 0;
            state = START;
          end
        end
        S_LOAD0: begin
          out_RD = 0;
          out_PLANE_SHIFT = 0;
          out_PLANE_LOAD0 = 0;
          out_PLANE_LOAD1 = 1;
          out_PLANE_READY = 0;
          reg_SIDE = 1;
          out_ROW_LOAD0 = 0;
          out_ROW_LOAD1 = 0;
          state = S_LOAD1;
        end
        S_LOAD1: begin
          out_RD = 0;
          out_PLANE_SHIFT = 0;
          out_PLANE_LOAD0 = 0;
          out_PLANE_LOAD1 = 0;
          out_PLANE_READY = 1;
          reg_SIDE = 0;
          out_ROW_LOAD0 = 0;
          out_ROW_LOAD1 = 0;
          state = DONE;
        end
        DONE: begin
          out_RD = 0;
          out_PLANE_SHIFT = 0;
          out_PLANE_LOAD0 = 0;
          out_PLANE_LOAD1 = 0;
          out_PLANE_READY = 0;
          reg_SIDE = 0;
          out_ROW_LOAD0 = 0;
          out_ROW_LOAD1 = 0;
          state = START;
        end
        S_CACHE_ROW0: begin
          if (in_VRAM_DONE_READ) begin
            out_RD = 0;
            out_PLANE_SHIFT = 0;
            out_PLANE_LOAD0 = 0;
            out_PLANE_LOAD1 = 0;
            out_PLANE_READY = 0;
            reg_SIDE = 0;
            out_ROW_LOAD0 = 1;
            out_ROW_LOAD1 = 0;
            state = S_LOAD_ROW0;
          end else begin
            out_RD = 0;
            out_PLANE_SHIFT = 0;
            out_PLANE_LOAD0 = 0;
            out_PLANE_LOAD1 = 0;
            out_PLANE_READY = 0;
            reg_SIDE = 0;
            out_ROW_LOAD0 = 0;
            out_ROW_LOAD1 = 0;
            state = S_CACHE_ROW0;
          end
        end
        S_LOAD_ROW0: begin
          out_RD = 1;
          out_PLANE_SHIFT = 0;
          out_PLANE_LOAD0 = 0;
          out_PLANE_LOAD1 = 0;
          out_PLANE_READY = 0;
          reg_SIDE = 1;
          out_ROW_LOAD0 = 0;
          out_ROW_LOAD1 = 0;
          state = S_CACHE_ROW1;
        end
        S_CACHE_ROW1: begin
          if (in_VRAM_DONE_READ) begin
            out_RD = 0;
            out_PLANE_SHIFT = 0;
            out_PLANE_LOAD0 = 0;
            out_PLANE_LOAD1 = 0;
            out_PLANE_READY = 0;
            reg_SIDE = 1;
            out_ROW_LOAD0 = 0;
            out_ROW_LOAD1 = 1;
            state = S_LOAD_ROW1;
          end else begin
            out_RD = 0;
            out_PLANE_SHIFT = 0;
            out_PLANE_LOAD0 = 0;
            out_PLANE_LOAD1 = 0;
            out_PLANE_READY = 0;
            reg_SIDE = 1;
            out_ROW_LOAD0 = 0;
            out_ROW_LOAD1 = 0;
            state = S_CACHE_ROW1;
          end
        end
        S_LOAD_ROW1: begin
          out_RD = 0;
          out_PLANE_SHIFT = 0;
          out_PLANE_LOAD0 = 1;
          out_PLANE_LOAD1 = 0;
          out_PLANE_READY = 0;
          reg_SIDE = 0;
          reg_row_cached = 1;
          out_ROW_LOAD0 = 0;
          out_ROW_LOAD1 = 0;
          state = S_LOAD0;
        end
        default: begin
          if (in_SHIFT_PLANE) begin
            out_RD = 0;
            out_PLANE_SHIFT = 1;
            out_PLANE_LOAD0 = 0;
            out_PLANE_LOAD1 = 0;
            out_PLANE_READY = 0;
            reg_row_cached = reg_row_cached;
            out_ROW_LOAD0 = 0;
            out_ROW_LOAD1 = 0;
            reg_SIDE = 0;
            state = SHIFT_P;
          end else if (in_CACHE) begin
            if (reg_row_cached) begin
              out_RD = 0;
              out_PLANE_SHIFT = 0;
              out_PLANE_LOAD0 = 1;
              out_PLANE_LOAD1 = 0;
              out_PLANE_READY = 0;
              reg_row_cached = reg_row_cached;
              reg_SIDE = 0;
              out_ROW_LOAD0 = 0;
              out_ROW_LOAD1 = 0;
              state = S_LOAD0;
            end else begin
              out_RD = 1;
              out_PLANE_SHIFT = 0;
              out_PLANE_LOAD0 = 0;
              out_PLANE_LOAD1 = 0;
              out_PLANE_READY = 0;
              reg_row_cached = 0;
              reg_SIDE = 0;
              out_ROW_LOAD0 = 0;
              out_ROW_LOAD1 = 0;
              state = S_CACHE_ROW0;
            end
          end
        end
      endcase
  end

`ifdef BENCH
  reg [8*40:1] state_name;
  always @(*) begin
    case (state)
      START: state_name = "START";
      SHIFT_P: state_name = "SHIFT_P";
      S_CACHE_ROW0: state_name = "S_CACHE_ROW0";
      S_LOAD0: state_name = "S_LOAD0";
      S_CACHE_ROW1: state_name = "S_CACHE_ROW1";
      S_LOAD1: state_name = "S_LOAD1";
      S_LOAD_ROW1: state_name = "S_LOAD_ROW1";
      S_LOAD_ROW0: state_name = "S_LOAD_ROW0";
      DONE: state_name = "DONE";
    endcase
  end
`endif
endmodule
