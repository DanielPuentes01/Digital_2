module run_CACHE (
    input clk,
    input in_INIT,
    input rst,
    input in_PLANE_READY_MM,
    output reg out_order_CACHE,
    output reg out_HUB75_INIT
);
  reg [1:0] state;
  parameter START = 0;
  parameter CACHE_WORKING = 1;
  parameter HUB75_STARTED = 2;

  always @(posedge clk) begin
    if (rst) begin
      out_order_CACHE = 0;
      out_HUB75_INIT = 0;
      state = START;
    end else
      case (state)
        START: begin
          if (in_INIT) begin
            out_order_CACHE = 1;
            out_HUB75_INIT = 0;
            state = CACHE_WORKING;
          end else begin
            out_order_CACHE = 0;
            out_HUB75_INIT = 0;
            state = START;
          end
        end
        CACHE_WORKING: begin
          if (in_PLANE_READY_MM) begin
            out_order_CACHE = 0;
            out_HUB75_INIT = 1;
            state = HUB75_STARTED;
          end else begin
            out_order_CACHE = 0;
            out_HUB75_INIT = 0;
            state = CACHE_WORKING;
          end
        end
        HUB75_STARTED: begin
          out_order_CACHE = 0;
          out_HUB75_INIT = 0;
          state = START;
        end
        default: state = START;
      endcase
  end

`ifdef BENCH
  reg [8*40:1] state_name;
  always @(*) begin
    case (state)
      START: state_name = "START";
      CACHE_WORKING: state_name = "CACHE_WORKING";
      HUB75_STARTED: state_name = "HUB75_STARTED";
    endcase
  end
`endif
endmodule
