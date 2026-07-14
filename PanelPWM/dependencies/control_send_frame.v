module control_send_frame (
  input clk,
  input rst,
  input init,
  input cont_clk_done,
  input cont_prio_done,
  input cont_ABCDE_done,
  input data_latch_done,
  input cont_col_done,
  output reg data_latch,
  output reg w_clk,
  output reg add_cont_col,
  output reg load_RGB,
  output reg add_cont_prio,
  output reg OE,
  output reg add_ABCDE,
  output reg rst_cont_ABCDE,
  output reg rst_cont_col,
  output reg add_cont_clk,
  output reg rst_cont_clk,
  output reg rst_cont_prio,
  output reg done
);
  reg [3:0] state;
  parameter INIT = 4'b0000;
  parameter ASSIGN_RGB = 4'b0001;
  parameter CLKUP1 = 4'b0010;
  parameter CLKDOWN1 = 4'b0011;
  parameter RST_CONT_PRIO_STATE = 4'b0100;
  parameter LATCHUP1 = 4'b0101;
  parameter CLKUP3 = 4'b0110;
  parameter CLKDOWN3 = 4'b0111;
  parameter OE_HIGH = 4'b1000;
  parameter RST_CONT_ABCDE = 4'b1001;
  parameter DONE = 4'b1010;


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
          state = cont_prio_done ? RST_CONT_PRIO_STATE : ASSIGN_RGB;
        end
        RST_CONT_PRIO_STATE: begin
          state = cont_col_done ? LATCHUP1 : ASSIGN_RGB;
        end
        LATCHUP1: begin
          state = data_latch_done ? CLKUP3 : LATCHUP1;
        end
        CLKUP3: begin
          state = CLKDOWN3;
        end
        CLKDOWN3: begin
          state = cont_clk_done ? OE_HIGH : CLKUP3;
        end
      
        OE_HIGH: begin
          state = cont_ABCDE_done ? RST_CONT_ABCDE : ASSIGN_RGB;
        end
        RST_CONT_ABCDE: begin
          state = DONE;
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
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        add_cont_prio = 0;
        OE = 1;
        add_ABCDE = 0;
        rst_cont_ABCDE = 1;
        rst_cont_col = 1;
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
        add_cont_prio = 0;
        OE = 1; 
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
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
        add_cont_prio = 0;
        OE = 1;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
         
        add_cont_clk = 0;
        rst_cont_clk = 0;
        rst_cont_prio = 0;
        done = 0;
      end
      CLKDOWN1: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        add_cont_prio = 1;
        OE = 1;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
        add_cont_clk = 0;
        rst_cont_clk = 0;
        rst_cont_prio = 0;
        done = 0;
      end
      RST_CONT_PRIO_STATE: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 1;
        load_RGB = 0;
        add_cont_prio = 0;
        OE = 1;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
        add_cont_clk = 0;
        rst_cont_clk = 0;
        rst_cont_prio = 1;
        done = 0;
      end
      LATCHUP1: begin
        data_latch = 1;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        add_cont_prio = 0;
        OE = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
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
        add_cont_prio = 0;
        OE = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
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
        add_cont_prio = 0;
        OE = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 0;
        rst_cont_col = 0;
        add_cont_clk = 1;
        rst_cont_clk = 0;
        rst_cont_prio = 0;
        done = 0;
      end
      OE_HIGH: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        add_cont_prio = 0;
        OE = 1;
        add_ABCDE = 1;
        rst_cont_ABCDE = 0;
        rst_cont_col = 1;
        add_cont_clk = 0;
        rst_cont_clk = 1;
        rst_cont_prio = 0;
        done = 0;
      end
      RST_CONT_ABCDE: begin
        data_latch = 0;
        w_clk = 0;
        add_cont_col = 0;
        load_RGB = 0;
        add_cont_prio = 0;
        OE = 1;
        add_ABCDE = 0;
        rst_cont_ABCDE = 1;
        rst_cont_col = 0;
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
        add_cont_prio = 0;
        OE = 1;
        add_ABCDE = 0;
        rst_cont_ABCDE = 1;
        rst_cont_col = 1;
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
        add_cont_prio = 0;
        OE = 0;
        add_ABCDE = 0;
        rst_cont_ABCDE = 1;
        rst_cont_col = 1;
        add_cont_clk = 0;
        rst_cont_clk = 1;
        rst_cont_prio = 1;
        done = 0;
      end
    endcase
  end
endmodule