module control_sendcfg (
  input clk,
  input rst,
  input init,
  input cont_cfg_done,
  input cont_chip_done,
  output reg rst_cont_cfg,
  output reg rst_cfg_reg,
  output reg rst_cont_chip,
  output reg shift_cfg,
  output reg add_cont_chip,
  output reg load_cfg_reg,
  output reg w_clk,
  output reg done
);
  
  reg [2:0] state;
  parameter INIT = 3'b000;
  parameter LOAD_CFG = 3'b001;
  parameter CLKUP = 3'b010;
  parameter CLKDOWN = 3'b011;
  parameter NEXT_CHIP = 3'b101;
  parameter SENDRGB = 3'b110;
  parameter DONE = 3'b111;

  always @(posedge clk) begin
    if(rst) begin
      state <= INIT;
    end
    else begin
      case(state)
        INIT: begin
          state = init ? LOAD_CFG : INIT;
        end
        SENDRGB: begin
          state = CLKUP;
        end
        CLKUP: begin
          state = CLKDOWN;
        end
        CLKDOWN: begin
          state = cont_cfg_done ? NEXT_CHIP : SENDRGB;
        end
        NEXT_CHIP: begin
          state = cont_chip_done ? DONE : LOAD_CFG;
        end
        LOAD_CFG: begin
          state = SENDRGB;
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
        rst_cont_cfg = 1;
        rst_cfg_reg = 1;
        rst_cont_chip = 1;
        shift_cfg = 0;
        add_cont_chip = 0;
        load_cfg_reg = 0;
        w_clk = 0;
        done = 0;
      end
      SENDRGB: begin
        rst_cont_cfg = 0;
        rst_cfg_reg = 0;
        rst_cont_chip = 0;
        shift_cfg = 0;
        add_cont_chip = 0;
        load_cfg_reg = 1;
        w_clk = 0;
        done = 0;
      end
      CLKUP: begin
        rst_cont_cfg = 0;
        rst_cfg_reg = 0;
        rst_cont_chip = 0;
        shift_cfg = 0;
        add_cont_chip = 0;
        load_cfg_reg = 0;
        w_clk = 1;
        done = 0;
      end
      CLKDOWN: begin
        rst_cont_cfg = 0;
        rst_cfg_reg = 0;
        rst_cont_chip = 0;
        shift_cfg = 1;
        add_cont_chip = 0;
        load_cfg_reg = 0;
        w_clk = 0;
        done = 0;
      end
      NEXT_CHIP: begin
        rst_cont_cfg = 1;
        rst_cfg_reg = 0;
        rst_cont_chip = 0;
        shift_cfg = 0;
        add_cont_chip = 1;
        load_cfg_reg = 0;
        w_clk = 0;
        done = 0;
      end
      LOAD_CFG: begin
        rst_cont_cfg = 0;
        rst_cfg_reg = 1;
        rst_cont_chip = 0;
        shift_cfg = 0;
        add_cont_chip = 0;
        load_cfg_reg = 0;
        w_clk = 0;
        done = 0;
      end
      DONE: begin
        rst_cont_cfg = 0;
        rst_cfg_reg = 0;
        rst_cont_chip = 1;
        shift_cfg = 0;
        add_cont_chip = 0;
        load_cfg_reg = 0;
        w_clk = 0;
        done = 1;
      end
      default: begin
        rst_cont_cfg = 0;
        rst_cfg_reg = 0;
        rst_cont_chip = 0;
        shift_cfg = 0;
        add_cont_chip = 0;
        load_cfg_reg = 0;
        w_clk = 0;
        done = 0;
      end
    endcase
  end
endmodule
