module control_panel_pwm(
  input clk,
  input rst, 
  input init,
  input pre_acts_done,
  input en_op_done,
  input wrcfg1_done,
  input wrcfg2_done,
  input wrcfg3_done,
  input wrcfg4_done,
  input sendcfg1_done,
  input sendcfg2_done,
  input sendcfg3_done,
  input sendcfg4_done,
  input vsync_done,
  input set_color_done,
  output reg pre_acts,
  output reg en_op,
  output reg wrcfg1,
  output reg wrcfg2,
  output reg wrcfg3,
  output reg wrcfg4,
  output reg sendcfg1,
  output reg sendcfg2,
  output reg sendcfg3,
  output reg sendcfg4,
  output reg vsync,
  output reg set_color,
  output reg done
);

  reg [4:0] state;

  parameter [4:0] INIT = 5'b00001;
  parameter [4:0] PRE_ACTS1 = 5'b00010;
  parameter [4:0] EN_OP1 = 5'b00011;
  parameter [4:0] SEND_CFG_1 = 5'b00100;
  parameter [4:0] PRE_ACTS2 = 5'b00101;
  parameter [4:0] WR_CFG_1 = 5'b00110;
  parameter [4:0] SEND_CFG_2 = 5'b00111;
  parameter [4:0] PRE_ACTS3 = 5'b01000;
  parameter [4:0] WR_CFG_2 = 5'b01001;
  parameter [4:0] SEND_CFG_3 = 5'b01010;
  parameter [4:0] PRE_ACTS4 = 5'b01011;
  parameter [4:0] WR_CFG_3 = 5'b01100;
  parameter [4:0] SEND_CFG_4 = 5'b01101;
  parameter [4:0] WR_CFG_4 = 5'b01111;
  parameter [4:0] SET_COLOR = 5'b10010;
  parameter [4:0] DONE = 5'b10011;
  parameter [4:0] PRE_ACTS6 = 5'b10100;

  always @(posedge clk) begin
    if (rst) begin
      state = INIT;
    end else begin
      case(state)
        INIT: begin
          state = init ? PRE_ACTS1 : INIT;
        end
        PRE_ACTS1: begin
          state = pre_acts_done ? EN_OP1 : PRE_ACTS1;
        end
        EN_OP1: begin
          state = en_op_done ? PRE_ACTS6 : EN_OP1;
        end
        PRE_ACTS6: begin
          state = pre_acts_done ? SEND_CFG_1 : PRE_ACTS6;
        end
        SEND_CFG_1: begin
          state = sendcfg1_done ? WR_CFG_1 : SEND_CFG_1;
        end
        PRE_ACTS2: begin
          state = pre_acts_done ? SEND_CFG_2 : PRE_ACTS2;
        end
        WR_CFG_1: begin
          state = wrcfg1_done ? PRE_ACTS2 : WR_CFG_1;
        end
        SEND_CFG_2: begin
          state = sendcfg2_done ? WR_CFG_2 : SEND_CFG_2;
        end
        PRE_ACTS3: begin
          state = pre_acts_done ? SEND_CFG_3 : PRE_ACTS3;
        end
        WR_CFG_2: begin
          state = wrcfg2_done ? PRE_ACTS3 : WR_CFG_2;
        end
        SEND_CFG_3: begin
          state = sendcfg3_done ? WR_CFG_3 : SEND_CFG_3;
        end
        PRE_ACTS4: begin
          state = pre_acts_done ? SEND_CFG_4 : PRE_ACTS4;
        end
        WR_CFG_3: begin
          state = wrcfg3_done ? PRE_ACTS4 : WR_CFG_3;
        end
        SEND_CFG_4: begin
          state = sendcfg4_done ? WR_CFG_4 : SEND_CFG_4;
        end
        WR_CFG_4: begin
          state = wrcfg4_done ? SET_COLOR : WR_CFG_4;
        end
        SET_COLOR: begin
          state = set_color_done ? DONE : SET_COLOR;
        end
        DONE: begin
          state = SET_COLOR;
        end
        default: begin
          state = INIT;
        end
      endcase
    end
  end

  always @(*) begin
    case (state)
      INIT: begin
        pre_acts = 0;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 0;
         
         
        done = 0;
      end 
      PRE_ACTS1: begin
        pre_acts = 1;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 0;
         
         
        done = 0;
      end 
      EN_OP1: begin
        pre_acts = 0;
        en_op = 1;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 0;
         
        done = 0;
      end 
      PRE_ACTS6: begin
        pre_acts = 1;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 0;
         
        done = 0;
      end 
      SEND_CFG_1: begin
        pre_acts = 0;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 1;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 0;
         
         
        done = 0;
      end 
      PRE_ACTS2: begin
        pre_acts = 1;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 0;
         
         
        done = 0;
      end 
      WR_CFG_1: begin
        pre_acts = 0;
        en_op = 0;
        wrcfg1 = 1;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 0;
         
         
        done = 0;
      end 
      SEND_CFG_2: begin
        pre_acts = 0;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 1;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 0;
         
         
        done = 0;
      end 
      PRE_ACTS3: begin
        pre_acts = 1;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 0;
         
         
        done = 0;
      end 
      WR_CFG_2: begin
        pre_acts = 0;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 1;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 0;
         
        done = 0;
      end 
      SEND_CFG_3: begin
        pre_acts = 0;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 1;
        sendcfg4 = 0;
        set_color = 0;
         
         
        done = 0;
      end 
      PRE_ACTS4: begin
        pre_acts = 1;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 0;
         
         
        done = 0;
      end 
      WR_CFG_3: begin
        pre_acts = 0;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 1;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 0;
         
         
        done = 0;
      end 
      SEND_CFG_4: begin
        pre_acts = 0;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 1;
        set_color = 0;
         
         
        done = 0;
      end 
      WR_CFG_4: begin
        pre_acts = 0;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 1;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 0;
         
        done = 0;
      end
      SET_COLOR: begin
        pre_acts = 0;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 1;
         
         
        done = 0;
      end 
      DONE: begin
        pre_acts = 0;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 0;
         
        done = 1;
      end 
      default: begin
        pre_acts = 0;
        en_op = 0;
        wrcfg1 = 0;
        wrcfg2 = 0;
        wrcfg3 = 0;
        wrcfg4 = 0;
        sendcfg1 = 0;
        sendcfg2 = 0;
        sendcfg3 = 0;
        sendcfg4 = 0;
        set_color = 0;
         
         
        done = 0;
      end
      
    endcase
  end




endmodule