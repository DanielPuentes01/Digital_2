module control_div (
    input clk,
    input rst,
    input init_in,
    input R_B_MSB,
    input in_K,

    output reg ctl_rst,
    output reg load_R,
    output reg shift,
    output reg decrement,
    output reg DONE
);

  parameter START = 3'b000;
  parameter SHIFT = 3'b001;
  parameter CHECK = 3'b010;
  parameter ADD = 3'b011;
  parameter CHECK2 = 3'b100;
  parameter END1 = 3'b101;

  reg [2:0] state;
  reg init_flag;
  always @(posedge clk) begin
    if (rst) begin
      state = START;
    end else begin
      case (state)
        START: begin
          state = init_in ? SHIFT : START;
          init_flag = 0;
        end
        SHIFT: begin
          init_flag = 0;
          state = CHECK;
        end
        CHECK: begin
          if (R_B_MSB == 0) state = ADD;
          else state = CHECK2;
        end
        ADD: state = CHECK2;
        CHECK2 : begin
          state = in_K ? END1 : SHIFT;
        end
        END1: begin
          state = init_flag ? SHIFT : END1;
          init_flag = init_in;//aqui el orden importa
          //si se declara primero init_flag = init_in
          //se pasa init_in directamente al if del estado
        end
        default: state = START;
      endcase
    end
  end

  always @(*) begin
    case (state)
      START: begin
        ctl_rst = 1;
        load_R = 0;
        shift = 0;
        decrement = 0;
        DONE = 0;
      end
      SHIFT: begin
        ctl_rst = 0;
        load_R = 0;
        shift = 1;
        decrement = 0;
        DONE = 0;
      end
      CHECK: begin
        ctl_rst = 0;
        load_R = 0;
        shift = 0;
        decrement = 1;
        DONE = 0;
      end
      ADD: begin
        ctl_rst = 0;
        load_R = 1;
        shift = 0;
        decrement = 0;
        DONE = 0;
      end
      CHECK2 : begin
        ctl_rst = 0;
        load_R = 0;
        shift = 0;
        decrement = 0;
        DONE = 0;
      end
      END1: begin
        ctl_rst = init_flag;
        load_R = 0;
        shift = 0;
        decrement = 0;
        load_R = 0;
        DONE = 1 ^ init_flag;
      end
      default: begin
        ctl_rst = 1;
        load_R = 0;
        shift = 0;
        decrement = 0;
        DONE = 0;
      end
    endcase
  end


`ifdef BENCH
  reg [8*40:1] state_name;
  always @(*) begin
    case (state)
      START:     state_name = "START";
      CHECK:     state_name = "CHECK";
      SHIFT: state_name = "SHIFT";
      ADD:       state_name = "ADD";
      CHECK2: state_name = "CHECK2";
      END1:      state_name = "END1";
    endcase
  end
`endif




endmodule
