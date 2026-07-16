module HUB75 (
    input clk,
    input rst,
    input in_INIT,
    input [2:0] in_RGB0,
    input [2:0] in_RGB1,
    input [4:0] in_ROW,
    input in_SHOW,
    input in_BRIGHT_DIM,
    output ctl_CLOKER_ITER,
    output ctl_HUB75_WAITING,
    output [2:0] w_RGB0,
    output [2:0] w_RGB1,
    output w_SCREEN_CLOCK,
    output [4:0] w_ABCDE,
    output w_LATCH,
    output w_nOE
);
  reg reg_WAITING;
  assign ctl_HUB75_WAITING = reg_WAITING;
  reg reg_LATCH;
  reg reg_nOE;
  assign w_nOE   = reg_nOE;
  assign w_LATCH = reg_LATCH;
  assign w_ABCDE = in_ROW;
  reg once_LATCHE;
  reg [2:0] state;
  parameter START = 0;
  parameter WAIT_ORDER = 1;
  parameter INIT_CLOCKER = 2;
  parameter CHECK = 3;
  parameter LATCHE = 4;
  parameter SHOW = 5;

  always @(negedge clk) begin
    if (rst) begin
      once_LATCHE = 0;
      state = START;
    end else begin
      case (state)
        START: begin
          once_LATCHE = 0;
          state = in_INIT ? INIT_CLOCKER : START;
        end
        INIT_CLOCKER: state = CHECK;
        CHECK: state = w_CLOCKER_FINISH ? WAIT_ORDER : CHECK;
        WAIT_ORDER: state = in_SHOW ? LATCHE : WAIT_ORDER;
        LATCHE: begin
          once_LATCHE = 1;
          state = SHOW;
        end
        SHOW: state = in_INIT ? INIT_CLOCKER : SHOW;
        default: state = START;
      endcase
    end
  end

  always @(*) begin
    case (state)
      START: begin
        reg_CLOCKER_INIT = 0;
        reg_CLOCKER_RST = 1;
        reg_LATCH = 0;
        reg_nOE = 1;
        reg_WAITING = 0;
      end
      WAIT_ORDER: begin
        reg_CLOCKER_INIT = 0;
        reg_CLOCKER_RST = 1;
        reg_LATCH = 0;
        reg_nOE = ~once_LATCHE | in_BRIGHT_DIM;
        reg_WAITING = 1;
      end
      INIT_CLOCKER: begin
        reg_CLOCKER_INIT = 1;
        reg_CLOCKER_RST = 0;
        reg_LATCH = 0;
        reg_nOE =  ~once_LATCHE | in_BRIGHT_DIM ;
        reg_WAITING = 0;
      end
      CHECK: begin
        reg_CLOCKER_INIT = 0;
        reg_CLOCKER_RST = 0;
        reg_LATCH = 0;
        reg_nOE = ~once_LATCHE | in_BRIGHT_DIM;
        reg_WAITING = 0;
      end
      LATCHE: begin
        reg_CLOCKER_INIT = 0;
        reg_CLOCKER_RST = 0;
        reg_LATCH = 1;
        reg_nOE = 1;
        reg_WAITING = 0;
      end
      SHOW: begin
        reg_CLOCKER_INIT = 0;
        reg_CLOCKER_RST = 1;
        reg_LATCH = 0;
        reg_nOE = 0 | in_BRIGHT_DIM;
        reg_WAITING = 0;
      end
      default: begin
        reg_CLOCKER_INIT = 0;
        reg_CLOCKER_RST = 1;
        reg_LATCH = 1;
        reg_nOE = 1;
        reg_WAITING = 0;
      end
    endcase
  end

  reg  reg_CLOCKER_RST;
  reg  reg_CLOCKER_INIT;
  wire w_CLOCKER_FINISH;
  wire w_CLOCKER_ITER;
  assign ctl_CLOKER_ITER = w_CLOCKER_ITER;
  RGB_clocker CLOCKER (
      .clk       (clk),
      .rst       (reg_CLOCKER_RST),
      .in_INIT   (reg_CLOCKER_INIT),
      .in_RGB0   (in_RGB0),
      .in_RGB1   (in_RGB1),
      .out_FINISH(w_CLOCKER_FINISH),
      .out_ITER  (w_CLOCKER_ITER),
      .out_RGB0  (w_RGB0),
      .out_RGB1  (w_RGB1),
      .S_CLOCK   (w_SCREEN_CLOCK)
  );

`ifdef BENCH
  reg [8*40:1] state_name;
  always @(*) begin
    case (state)
      START:        state_name = "START";
      INIT_CLOCKER: state_name = "INIT_CLOCKER";
      CHECK:        state_name = "CHECK";
      WAIT_ORDER:   state_name = "WAIT_ORDER";
      LATCHE:       state_name = "LATCHE";
      SHOW:         state_name = "SHOW";
    endcase
  end
`endif

endmodule
