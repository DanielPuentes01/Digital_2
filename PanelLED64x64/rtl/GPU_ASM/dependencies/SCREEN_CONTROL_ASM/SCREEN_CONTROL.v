module SCREEN_CONTROL #(
    parameter RESOLUTION = 3
) (
    input clk,
    input rst,
    input in_signal_PLANE_READY_MM,
    input in_signal_HUB75_WAITING,
    input in_signal_HUB75_ITER,
    output wire out_signal_BRIGHT_DIM,
    output out_signal_SHIFT_PLANE,
    output wire [1:0] out_PLANE_SELECT_MM,
    output wire out_signal_CACHE,
    output wire out_signal_HUB75_INIT,
    output out_signal_HUB75_SHOW,
    output out_signal_HUB75_RST,
    output [4:0] out_ROW
);
  assign out_signal_SHIFT_PLANE = in_signal_HUB75_ITER;
  assign out_signal_HUB75_SHOW  = w_synced_HUB75_SHOW;
  assign out_signal_HUB75_RST   = w_synced_HUB75_RST | reg_RST;
  assign out_signal_HUB75_INIT  = w_inter_HUB75_INIT;
  wire w_inter_HUB75_INIT;
  wire w_synced_HUB75_SHOW;
  wire w_synced_HUB75_RST;
  reg  reg_RST;
  reg  reg_CACHE_INIT;
  reg  reg_ROW_P;
  reg  reg_PLANE_SELECT_P;
  reg  reg_BCM_INIT;
  reg  reg_BCM_PLS_RST;
  reg  reg_BCM_CONTINUE;
  reg  reg_HUB75_SHOW;
  reg  reg_HUB75_RST;
  wire w_BCM_FINISH;
  wire w_BCM_NEXT_PLANE;

  parameter START = 0;
  parameter ONCE_CACHE_WAITING = 1;
  parameter ONCE_SHOW = 2;
  parameter BCM_INIT_Y_CACHE = 3;
  parameter WORKING = 4;
  parameter HUB75_SHOW = 5;
  parameter PLANE_P = 6;
  parameter HUB75_RST = 7;
  reg [3:0] state;
  always @(negedge clk) begin
    if (rst) begin
      reg_RST = 1;
      reg_CACHE_INIT = 0;
      reg_ROW_P = 0;
      reg_PLANE_SELECT_P = 0;
      reg_BCM_INIT = 0;
      reg_BCM_PLS_RST = 1;
      reg_HUB75_RST = 1;
      reg_BCM_CONTINUE = 0;
      reg_HUB75_SHOW = 0;
      state = START;
    end else begin
      case (state)
        START: begin
          reg_RST = 0;
          reg_CACHE_INIT = 1;
          reg_ROW_P = 0;
          reg_PLANE_SELECT_P = 0;
          reg_BCM_INIT = 0;
          reg_BCM_PLS_RST = 0;
          reg_HUB75_RST = 0;
          reg_BCM_CONTINUE = 0;
          reg_HUB75_SHOW = 0;
          state = ONCE_CACHE_WAITING;
        end
        ONCE_CACHE_WAITING: begin
          reg_RST = 0;
          reg_CACHE_INIT = 0;
          reg_ROW_P = 0;
          reg_PLANE_SELECT_P = in_signal_HUB75_WAITING;
          reg_BCM_INIT = 0;
          reg_BCM_PLS_RST = 0;
          reg_HUB75_RST = 0;
          reg_BCM_CONTINUE = 0;
          reg_HUB75_SHOW = in_signal_HUB75_WAITING;
          state = in_signal_HUB75_WAITING ? ONCE_SHOW : ONCE_CACHE_WAITING;
        end
        ONCE_SHOW: begin
          reg_RST = 0;
          reg_CACHE_INIT = 1;
          reg_ROW_P = 0;
          reg_PLANE_SELECT_P = 0;
          reg_BCM_INIT = 1;
          reg_BCM_PLS_RST = 0;
          reg_BCM_CONTINUE = 0;
          reg_HUB75_RST = 0;
          reg_HUB75_SHOW = 0;
          state = BCM_INIT_Y_CACHE;
        end
        BCM_INIT_Y_CACHE: begin
          reg_RST = 0;
          reg_CACHE_INIT = 0;
          reg_ROW_P = 0;
          reg_PLANE_SELECT_P = 0;
          reg_BCM_INIT = 0;
          reg_BCM_PLS_RST = 0;
          reg_BCM_CONTINUE = 0;
          reg_HUB75_RST = 0;
          reg_HUB75_SHOW = 0;
          state = WORKING;
        end
        WORKING: begin
          reg_RST = 0;
          reg_CACHE_INIT = 0;
          reg_ROW_P = 0;
          reg_PLANE_SELECT_P = 0;
          reg_BCM_INIT = 0;
          reg_BCM_PLS_RST = 0;
          reg_BCM_CONTINUE = 0;
          reg_HUB75_RST = w_BCM_FINISH;
          reg_HUB75_SHOW = in_signal_HUB75_WAITING & w_BCM_NEXT_PLANE;
          if (w_BCM_FINISH) state = HUB75_RST;
          else if (in_signal_HUB75_WAITING & w_BCM_NEXT_PLANE) state = HUB75_SHOW;
          else state = WORKING;
        end
        HUB75_RST: begin
          reg_RST = &out_ROW;  //se evalua a 1 si todos los bits son 1
          reg_CACHE_INIT = 0;
          reg_ROW_P = ~&out_ROW;  //se evalua a 0 si todos los bits son 1
          reg_PLANE_SELECT_P = 0;
          reg_BCM_INIT = 0;
          reg_BCM_PLS_RST = 1;
          reg_BCM_CONTINUE = 0;
          reg_HUB75_RST = 0;
          reg_HUB75_SHOW = 0;
          state = START;
        end
        HUB75_SHOW: begin
          reg_RST = 0;
          reg_CACHE_INIT = 0;
          reg_ROW_P = 0;
          reg_PLANE_SELECT_P = out_PLANE_SELECT_MM != (RESOLUTION-1);
          reg_BCM_INIT = 0;
          reg_BCM_PLS_RST = 0;
          reg_BCM_CONTINUE = 1;
          reg_HUB75_RST = 0;
          reg_HUB75_SHOW = 0;
          state = out_PLANE_SELECT_MM != (RESOLUTION-1) ? PLANE_P : WORKING;
        end
        PLANE_P : begin
          reg_RST = 0;
          reg_CACHE_INIT = 1;
          reg_ROW_P = 0;
          reg_PLANE_SELECT_P = 0;
          reg_BCM_INIT = 0;
          reg_BCM_PLS_RST = 0;
          reg_BCM_CONTINUE = 0;
          reg_HUB75_RST = 0;
          reg_HUB75_SHOW = 0;
          state = WORKING;
        end
        default: begin
          reg_RST = 1;
          reg_CACHE_INIT = 0;
          reg_ROW_P = 0;
          reg_PLANE_SELECT_P = 0;
          reg_BCM_INIT = 0;
          reg_BCM_PLS_RST = 1;
          reg_HUB75_RST = 1;
          reg_BCM_CONTINUE = 0;
          reg_HUB75_SHOW = 0;
          state = START;
        end
      endcase
    end
  end
  acumulador #(
      .WIDTH(5),
      .RST_VALUE(0),
      .PLUS_VALUE(1),
      .POS_EDGE(1)
  ) u_acumulador_row (
      .clk  (clk),
      .rst  (reg_RST),
      .plus (reg_ROW_P),
      .value(out_ROW)
  );

  acumulador #(
      .WIDTH(2),
      .RST_VALUE(0),
      .PLUS_VALUE(1),
      .POS_EDGE(1)
  ) u_acumulador_plane_select (
      .clk  (clk),
      .rst  (reg_BCM_PLS_RST),
      .plus (reg_PLANE_SELECT_P),
      .value(out_PLANE_SELECT_MM)
  );

  BCM u_BCM (
      .clk           (~clk),
      .rst           (reg_BCM_PLS_RST),
      .in_INIT       (reg_BCM_INIT),
      .in_CONTINUE   (reg_BCM_CONTINUE),
      .out_NEXT_PLANE(w_BCM_NEXT_PLANE),
      .out_FINISHED  (w_BCM_FINISH),
      .out_BRIGH_DIM (out_signal_BRIGHT_DIM)
  );

  run_CACHE u_run_CACHE (
      .clk              (clk),
      .in_INIT          (reg_CACHE_INIT),
      .rst              (reg_RST),
      .in_PLANE_READY_MM(in_signal_PLANE_READY_MM),
      .out_order_CACHE  (out_signal_CACHE),
      .out_HUB75_INIT   (w_inter_HUB75_INIT)
  );

  hub75_sync u_hub75_sync_show (
      .clk             (clk),
      .rst             (reg_RST),
      .in_sync_hub75   (reg_HUB75_SHOW),
      .out_synced_hub75(w_synced_HUB75_SHOW)
  );

  hub75_sync u_hub75_sync_rst (
      .clk             (clk),
      .rst             (reg_RST),
      .in_sync_hub75   (reg_HUB75_RST),
      .out_synced_hub75(w_synced_HUB75_RST)
  );



`ifdef BENCH
  reg [8*40:1] state_name;
  always @(*) begin
    case (state)
      START: state_name = "START";
      ONCE_CACHE_WAITING: state_name = "ONCE_CACHE_WAITING";
      ONCE_SHOW: state_name = "ONCE_SHOW";
      BCM_INIT_Y_CACHE: state_name = "BCM_INIT_Y_CACHE";
      WORKING: state_name = "WORKING";
      HUB75_RST: state_name = "HUB75_RST";
      HUB75_SHOW: state_name = "HUB75_SHOW";
      PLANE_P: state_name = "PLANE_P";
    endcase
  end
`endif

endmodule
