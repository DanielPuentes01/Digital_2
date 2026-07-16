module RGB_clocker (
    input clk,
    input rst,
    input in_INIT,
    input [2:0] in_RGB0,
    input [2:0] in_RGB1,
    output reg out_FINISH,
    output out_ITER,
    output [2:0] out_RGB0,
    output [2:0] out_RGB1,
    output S_CLOCK
);
  reg reg_LEDS_RST;
  reg reg_LEDS_L;
  assign out_ITER = reg_LEDS_L;
  assign S_CLOCK  = clk & reg_LEDS_L;
  wire w_K;

  assign out_RGB0 = in_RGB0;
  assign out_RGB1 = in_RGB1;

  reg [1:0] state;
  parameter START = 2'b00;
  parameter ITER = 2'b01;
  parameter FINISH = 2'b10;

  always @(posedge clk) begin
    if (rst) begin
      state = START;
      reg_LEDS_RST = 1;
      reg_LEDS_L = 0;
      out_FINISH = 0;
    end else
      case (state)
        START: begin
          if (in_INIT) begin
            state = ITER;
            reg_LEDS_RST = 0;
            reg_LEDS_L = 1;
            out_FINISH = 0;
          end else begin
            state = START;
            reg_LEDS_RST = 1;
            reg_LEDS_L = 0;
            out_FINISH = 0;
          end
        end
        ITER: begin
          if (w_K) begin
            state = FINISH;
            reg_LEDS_RST = 0;
            reg_LEDS_L = 0;
            out_FINISH = 1;
          end else begin
            state = ITER;
            reg_LEDS_RST = 0;
            reg_LEDS_L = 1;
            out_FINISH = 0;
          end
        end
        FINISH: begin
          state = FINISH;
          reg_LEDS_RST = 0;
          reg_LEDS_L = 0;
          out_FINISH = 1;
        end
        default: begin
          if (in_INIT) begin
            state = ITER;
            reg_LEDS_RST = 0;
            reg_LEDS_L = 1;
            out_FINISH = 0;
          end else begin
            state = START;
            reg_LEDS_RST = 1;
            reg_LEDS_L = 0;
            out_FINISH = 0;
          end
        end
      endcase
  end

  acumulador_restando #(
      .REG_WIDTH (7),
      .RST_VALUE (64),
      .LESS_VALUE(1)
  ) LEDS (
      .rst  (reg_LEDS_RST),
      .clk  (clk),
      .less (reg_LEDS_L),
      .out_K(w_K)
  );

`ifdef BENCH
  reg [8*40:1] state_name;
  always @(*) begin
    case (state)
      START:        state_name = "START";
      ITER: state_name = "ITER";
      FINISH:        state_name = "FINISH";
    endcase
  end
`endif

endmodule
