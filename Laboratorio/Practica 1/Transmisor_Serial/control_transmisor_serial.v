module control_transmisor_serial(
  clk,
  rst,
  init,
  z,
  k,
  busy,
  out_rst,
  done,
  load,
  add_tick,
  add_bit
);

  input clk;
  input rst;
  input init;
  input z;
  input k;

  output reg busy;
  output reg done;
  output reg load;
  output reg out_rst;
  output reg add_tick;
  output reg add_bit;

  parameter START = 3'b000;
  parameter LOAD = 3'b001;
  parameter CONTAR_TICK = 3'b011;
  parameter SFT = 3'b100;
  parameter DONE = 3'b101;

  reg [2:0] state;

  always @(negedge clk) begin
    if (rst) begin
      state = START;
    end else begin
      case (state) 
        START : begin
          state = init ? LOAD : START;
        end

        LOAD : begin
          state = CONTAR_TICK;
        end

        CONTAR_TICK : begin
          state = z ? SFT : CONTAR_TICK;
        end

        SFT : begin
          state = k ? DONE : CONTAR_TICK;
        end

        DONE : begin
          state = START;
        end

        default : begin
          state = START;
        end

      endcase
    end 
  end

  always @(*) begin
    case (state)
      START : begin
        out_rst = 1;
        busy = 0;
        done = 0;
        load = 0;
        add_tick = 0;
        add_bit = 0;
      end

      LOAD : begin
        busy = 0;
        out_rst = 0;
        done = 0;
        load = 1;
        add_tick = 0;
        add_bit = 0;
      end

      CONTAR_TICK : begin
        busy = 1;
        out_rst = 0;
        done = 0;
        load = 0;
        add_tick = 1;
        add_bit = 0;
      end

      SFT : begin
        busy = 1;
        out_rst = 0;
        done = 0;
        load = 0;
        add_tick = 0;
        add_bit = 1;
      end

      DONE : begin
        busy = 0;
        out_rst = 0;
        done = 1;
        load = 0;
        add_tick = 0;
        add_bit = 0;
      end

      default : begin
        busy = 0;
        done = 0;
        load = 0;
        out_rst = 0;
        add_tick = 0;
        add_bit = 0;
      end
    endcase
    
  end

endmodule