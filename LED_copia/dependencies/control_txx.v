module control_contar_blanco (
    clk,
    rst,
    init,
    k,
    done,
    plus,
    out_rst
);

  input clk;
  input rst;
  input init;
  input k;

  output reg plus;
  output reg out_rst;
  output reg done;

  parameter START = 2'b00;
  parameter ACC = 2'b01;
  parameter DONE = 2'b11;

  reg [1:0] state;

  always @(negedge clk) begin
    if (rst) begin
      state = START;
    end else begin
      case (state)

        START: begin
          state = init ? ACC : START;
        end

        ACC: begin
          if (k) begin
            state = DONE;
          end else state = ACC;
        end

        DONE: begin
          state = START;
        end

        default: state = START;

      endcase
    end

  end

  always @(*) begin
    case (state)
      START: begin
        plus = 0;
        done = 0;
        out_rst = 1;
      end

      ACC: begin
        plus = 1;
        done = 0;
        out_rst = 0;
      end

      DONE: begin
        plus = 0;
        done = 1;
        out_rst = 0;
      end
      default: begin
        plus = 0;
        done = 0;
        out_rst = 1;
      end
    endcase
  end

`ifdef BENCH
  reg [8*40:1] state_name;
  always @(*) begin
    case (state)
      START: state_name = "START";
      ACC:   state_name = "ACC";
      DONE:  state_name = "DONE";
    endcase

  end
`endif

endmodule
