module control_counter (
  clk,
  init,
  rst,
  out_rst,
  z,
  a0,
  sft,
  add,
  done
);
  input clk;
  input init;
  input rst;

  input z;
  input a0;

  output reg out_rst;
  output reg sft;
  output reg done;
  output reg add;

  parameter START = 3'b000;
  parameter CHECK1 = 3'b001;
  parameter ADD = 3'b010;
  parameter SHIFT = 3'b011;
  parameter CHECK2 = 3'b100;
  parameter DONE = 3'b101;

  reg [2:0] state;

  always @(negedge clk) begin
    if (rst) begin
      state = START;
    end else begin
      case (state)

        START : begin
          state = init ? CHECK1 : START;
        end

        CHECK1 : begin
          state = a0 ? ADD : SHIFT;
        end

        ADD : begin
          state = SHIFT;
        end

        SHIFT : begin
          state = CHECK2;
        end

        CHECK2 : begin
          state = z ? DONE : CHECK1;
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
        sft = 0;
        done = 0;
        add = 0;
      end 
      CHECK1 : begin
        out_rst = 0;
        sft = 0;
        done = 0;
        add = 0;
      end 
      ADD : begin
        out_rst = 0;
        sft = 0;
        done = 0;
        add = 1;
      end 
      SHIFT : begin
        out_rst = 0;
        sft = 1;
        done = 0;
        add = 0;
      end 
      CHECK2 : begin
        out_rst = 0;
        sft = 0;
        done = 0;
        add = 0;
      end 
      DONE : begin
        out_rst = 0;
        sft = 0;
        done = 1;
        add = 0;
      end 
      default : begin
        out_rst = 1;
        sft = 0;
        done = 0;
        add = 0;
      end  
    endcase
  end
endmodule