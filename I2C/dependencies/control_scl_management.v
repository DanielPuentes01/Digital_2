module control_scl_management (
    clk,
    rst,
    init,
    done,
    SCL_M,
    out_rst,
    cont_clk_s,
    cont_clk_done
);

  input clk;
  input rst;
  input init;
  input cont_clk_done;

  output reg done;
  output reg SCL_M;
  output reg cont_clk_s;
  output reg out_rst;

  parameter START = 3'b000;
  parameter CONT_CLK1 = 3'b001;
  parameter SCL1 = 3'b010;
  parameter CONT_CLK2 = 3'b011;
  parameter DONE = 3'b100;

  reg [2:0] state;

  always @(posedge clk) begin
    if (rst) begin
      state = START;
    end else begin
      case (state)
        START: begin
          state = init ? CONT_CLK1 : START;
        end
        CONT_CLK1: begin
          state = cont_clk_done ? SCL1 : CONT_CLK1;
        end
        SCL1: begin
          state = CONT_CLK2;
        end
        CONT_CLK2: begin
          state = cont_clk_done ? DONE : CONT_CLK2;
        end
        DONE: begin
          state = START;
        end
        
        default: begin
          state = START;
        end

      endcase
    end
  end

  always @(*) begin
    case (state)
      START: begin
        SCL_M = 0;
        cont_clk_s = 0;
        out_rst = 1;
        done = 0;
      end
      CONT_CLK1: begin
        SCL_M = 0;
        cont_clk_s = 1;
        out_rst = 0;
        done = 0;
      end
      SCL1: begin
        SCL_M = 1;
        cont_clk_s = 0;
        out_rst = 1;
        done = 0;
      end
      CONT_CLK2: begin
        SCL_M = 1;
        cont_clk_s = 1;
        out_rst = 0;
        done = 0;
      end
      DONE: begin
        SCL_M = 0;
        cont_clk_s = 0;
        out_rst = 1;
        done = 1;
      end
      default: begin
        SCL_M = 0;
        cont_clk_s = 0;
        out_rst = 1;
        done = 0;
      end
    endcase
  end


endmodule 