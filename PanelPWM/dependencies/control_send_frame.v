module control_send_frame (
  input clk,
  input rst,
  input init,
  input cont_clk_done,
  input cont_prio_done,
  input this_prio_done,
  input cont_ABCDE_done,
  input data_latch_done,
  input cont_col_done,
  output reg data_latch,
  output reg w_clk,
  output reg add_cont_col,
  output reg load_RGB,
  output reg rest_cont_prio,
  output reg OE,
  output reg rest_this_prio,
  output reg add_ABCDE,
  output reg rst_cont_ABCDE,
  output reg rst_cont_col,
  output reg rst_this_prio,
  output reg add_cont_clk,
  output reg rst_cont_clk,
  output reg rst_cont_prio,
  output reg done
);
  reg [4:0] state;
  parameter INIT = 5'b00000;
  parameter ASSIGN_RGB = 5'b00001;
  parameter CLKUP1 = 5'b00010;
  parameter CLKDOWN1 = 5'b00011;
  parameter LATCHUP1 = 5'b00100;
  parameter CLKUP3 = 5'b01000;
  parameter CLKDOWN3 = 5'b01001;
  parameter RST_CONT_CLK = 5'b01010;
  parameter REST_CONT_PRIO = 5'b01011;
  parameter OE_HIGH = 5'b01100;
  parameter ASSIGN_CONT_PRIO1 = 5'b01101;
  parameter RST_THIS_PRIO = 5'b01110;
  parameter ASSIGN_CONT_PRIO2 = 5'b01111;
  parameter RST_CONT_ABCDE = 5'b10000;
  parameter DONE = 5'b10001;

  always @(posedge clk) begin
    if(rst) begin
      state = INIT;
    end
    else begin
      case(state)
        INIT: begin
          state = init ? ASSIGN_RGB : INIT;
        end
        ASSIGN_RGB: begin
          state = CLKUP1;
        end
        CLKUP1: begin
          state = CLKDOWN1;
        end
        CLKDOWN1: begin
          state = cont_col_done ? LATCHUP1 : ASSIGN_RGB;
        end
        LATCHUP1: begin
          state = data_latch_done ? CLKUP3 : LATCHUP1;
        end
        CLKUP3: begin
          state = CLKDOWN3;
        end
        CLKDOWN3: begin
          state = cont_clk_done ? RST_CONT_CLK : CLKUP3;
        end
        RST_CONT_CLK: begin
          state = cont_prio_done ? OE_HIGH : REST_CONT_PRIO;
        end
        REST_CONT_PRIO: begin
          state = CLKUP3;
        end
        OE_HIGH: begin
          state = ASSIGN_CONT_PRIO1;
        end
        ASSIGN_CONT_PRIO1: begin
          state = cont_ABCDE_done ? RST_CONT_ABCDE : ASSIGN_RGB;
        end
        RST_CONT_ABCDE: begin
          state = ASSIGN_CONT_PRIO2;
        end
        ASSIGN_CONT_PRIO2: begin
          state = this_prio_done ? RST_THIS_PRIO : ASSIGN_RGB;
        end
        RST_THIS_PRIO: begin
          state = DONE;
        end
        DONE: begin
          state = ASSIGN_RGB;
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
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        rest_cont_prio = 0;
        OE = 0;
        rest_this_prio = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 1;
        rst_cont_col = 1;
        rst_this_prio = 1;
        add_cont_clk = 0;
        rst_cont_clk = 1;
        rst_cont_prio = 1;
        done = 0;
      end
      ASSIGN_RGB: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 1;
        rest_cont_prio = 0;
        OE = 1;
        rest_this_prio = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
        rst_this_prio = 0;
        add_cont_clk = 0;
        rst_cont_clk = 0;
        rst_cont_prio = 0;
        done = 0;
      end
      CLKUP1: begin
        data_latch = 0;
        w_clk = 1;
        add_cont_col = 0;
        load_RGB = 0;
        rest_cont_prio = 0;
        OE = 1;
        rest_this_prio = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
        rst_this_prio = 0;
        add_cont_clk = 0;
        rst_cont_clk = 0;
        rst_cont_prio = 0;
        done = 0;
      end
      CLKDOWN1: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 1;
        load_RGB = 0;
        rest_cont_prio = 0;
        OE = 1;
        rest_this_prio = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
        rst_this_prio = 0;
        add_cont_clk = 0;
        rst_cont_clk = 0;
        rst_cont_prio = 0;
        done = 0;
      end
      LATCHUP1: begin
        data_latch = 1;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        rest_cont_prio = 0;
        OE = 1;
        rest_this_prio = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
        rst_this_prio = 0;
        add_cont_clk = 0;
        rst_cont_clk = 0;
        rst_cont_prio = 0;
        done = 0;
      end
      CLKUP3: begin
        data_latch = 0;
        w_clk = 1;
        add_cont_col = 0;
        load_RGB = 0;
        rest_cont_prio = 0;
        OE = 0;
        rest_this_prio = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
        rst_this_prio = 0;
        add_cont_clk = 0;
        rst_cont_clk = 0;
        rst_cont_prio = 0;
        done = 0;
      end
      CLKDOWN3: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        rest_cont_prio = 0;
        OE = 0;
        rest_this_prio = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
        rst_this_prio = 0;
        add_cont_clk = 1;
        rst_cont_clk = 0;
        rst_cont_prio = 0;
        done = 0;
      end
      RST_CONT_CLK: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        rest_cont_prio = 0;
        OE = 0;
        rest_this_prio = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
        rst_this_prio = 0;
        add_cont_clk = 0;
        rst_cont_clk = 1;
        rst_cont_prio = 0;
        done = 0;
      end
      REST_CONT_PRIO: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        rest_cont_prio = 1;
        OE = 0;
        rest_this_prio = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
        rst_this_prio = 0;
        add_cont_clk = 0;
        rst_cont_clk = 0;
        rst_cont_prio = 0;
        done = 0;
      end
      OE_HIGH: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        rest_cont_prio = 0;
        OE = 1;
        rest_this_prio = 0;
        add_ABCDE = 1;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
        rst_this_prio = 0;
        add_cont_clk = 0;
        rst_cont_clk = 0;
        rst_cont_prio = 0;
        done = 0;
      end
      ASSIGN_CONT_PRIO1: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        rest_cont_prio = 0;
        OE = 1;
        rest_this_prio = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
        rst_this_prio = 0;
        add_cont_clk = 0;
        rst_cont_clk = 0;
        rst_cont_prio = 1;
        done = 0;
      end
      RST_CONT_ABCDE: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        rest_cont_prio = 0;
        OE = 1;
        rest_this_prio = 1;
        add_ABCDE = 0;
        rst_cont_ABCDE = 1;
        rst_cont_col = 0;
        rst_this_prio = 0;
        add_cont_clk = 0;
        rst_cont_clk = 0;
        rst_cont_prio = 0;
        done = 0;
      end
      ASSIGN_CONT_PRIO2: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        rest_cont_prio = 0;
        OE = 1;
        rest_this_prio = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
        rst_this_prio = 1;
        add_cont_clk = 0;
        rst_cont_clk = 0;
        rst_cont_prio = 0;
        done = 0;
      end
      RST_THIS_PRIO: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        rest_cont_prio = 0;
        OE = 1;
        rest_this_prio = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
        rst_this_prio = 1;
        add_cont_clk = 0;
        rst_cont_clk = 0;
        rst_cont_prio = 0;
        done = 0;
      end
      DONE: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        rest_cont_prio = 0;
        OE = 1;
        rest_this_prio = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 1;
        rst_cont_col = 1;
        rst_this_prio = 1;
        add_cont_clk = 0;
        rst_cont_clk = 1;
        rst_cont_prio = 1;
        done = 1;
      end
      default: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        rest_cont_prio = 0;
        OE = 0;
        rest_this_prio = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 1;
        rst_cont_col = 1;
        rst_this_prio = 1;
        add_cont_clk = 0;
        rst_cont_clk = 1;
        rst_cont_prio = 1;
        done = 0;
      end
    endcase
  end
endmodule