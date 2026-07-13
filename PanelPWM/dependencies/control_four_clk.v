module control_four_clk(
    input clk,
    input rst,
    input init,
    input cont_done,
    output reg w_clk,
    output reg add_cont,
    output reg rst_cont,
    output reg done
);

  reg [1:0] state;
  localparam INIT    = 2'd0;
  localparam CLK_UP  = 2'd1;
  localparam CLK_DWN = 2'd2;
  localparam DONE    = 2'd3;

  always @(posedge clk) begin
    if (rst)
      state <= INIT;
    else begin
      case(state)
        INIT:
          state = init ? CLK_UP : INIT;

        CLK_UP:
          state = CLK_DWN;

        CLK_DWN:
          state = cont_done ? DONE : CLK_UP;

        DONE:
          state = INIT;

        default:
          state = INIT;
      endcase
    end
  end

  always @(*) begin
    case(state)
      INIT: begin
        w_clk    = 0;
        add_cont = 0;
        rst_cont = 1;
        done     = 0;
      end
      CLK_UP:begin
        w_clk    = 1;
        add_cont = 0;
        rst_cont = 0;
        done     = 0;
      end
      CLK_DWN:begin
        w_clk    = 0;
        add_cont = 1;
        rst_cont = 0;
        done     = 0;
      end
      DONE: begin
        w_clk    = 0;
        add_cont = 0;
        rst_cont = 1;
        done     = 1;
      end
    endcase
  end
endmodule