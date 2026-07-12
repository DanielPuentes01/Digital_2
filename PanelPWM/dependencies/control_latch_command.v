module control_latch_command (
  input clk,
  input rst,
  input init,
  input cont_clk_done,
  output reg latch,
  output reg w_clk,
  output reg add_cont_clk,
  output reg rst_cont_clk,
  output reg done
);

  reg [2:0] state;
  parameter INIT = 3'b000;
  parameter LATCH = 3'b001;
  parameter CLKUP = 3'b010;
  parameter CLKDOWN = 3'b011;
  parameter DONE = 3'b111;

  always @(posedge clk) begin
    if(rst) begin
      state <= INIT;
    end
    else begin
      case(state)
        INIT: begin
          state = init ? LATCH : INIT;
        end
        LATCH: begin
          state = CLKUP;
        end
        CLKUP: begin
          state = CLKDOWN;
        end
        CLKDOWN: begin
          state = cont_clk_done ? DONE : CLKUP;
        end
        DONE: begin
          state = INIT;
        end
        default: begin
          state = INIT;
        end
      endcase
    end
  end

  always @(*) begin
    case(state)
      INIT: begin
        latch = 0;
        w_clk = 0;
        add_cont_clk = 0;
        rst_cont_clk = 1;
        done = 0;
      end
      LATCH: begin
        latch = 1;
        w_clk = 0;
        add_cont_clk = 0;
        rst_cont_clk = 0;
        done = 0;
      end
      CLKUP: begin
        latch = 1;
        w_clk = 1;
        add_cont_clk = 0;
        rst_cont_clk = 0;
        done = 0;
      end
      CLKDOWN: begin
        latch = 1;
        w_clk = 0;
        add_cont_clk = 1;
        rst_cont_clk = 0;
        done = 0;
      end
      DONE: begin
        latch = 0;
        w_clk = 0;
        add_cont_clk = 0;
        rst_cont_clk = 1;
        done = 1;
      end
      default: begin
        latch = 0;
        w_clk = 0;
        add_cont_clk = 0;
        rst_cont_clk = 1;
        done = 0;
      end
    endcase
  end

  

endmodule