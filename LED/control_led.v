module control_led (
  clk,
  rst,
  init,
  T1H_done,
  T1L_done,
  T0H_done,
  T0L_done,
  RST_timer_done,
  MSBColor,
  T1H_s,
  T1L_s,
  T0H_s,
  T0L_s,
  RST_timer_s,
  k,
  load,
  sft,
  DIN
);  
  input clk;
  input rst;
  input init;
  input T1H_done;
  input T1L_done;
  input T0H_done;
  input T0L_done;
  input RST_timer_done;
  input MSBColor;
  input k;

  output reg T1H_s;
  output reg T1L_s;
  output reg T0H_s;
  output reg T0L_s;
  output reg RST_timer_s;
  output reg load;
  output reg sft;
  output reg DIN;


  reg [3:0] state;

  parameter START = 4'b0000;
  parameter LOAD = 4'b0001;
  parameter CHECK = 4'b0010;
  parameter T1H = 4'b0011;
  parameter T1L = 4'b0100;
  parameter T0H = 4'b0101;
  parameter T0L = 4'b0110;
  parameter SHIFT = 4'b0111;
  parameter RESET = 4'b1000;

  always @(negedge clk) begin
    if (rst) begin
      state = START;
    end else begin
      case (state)

        START: begin
          state = init ? LOAD : START;
        end

        LOAD: begin
          state = CHECK;
        end

        CHECK: begin
          if (MSBColor) begin
            state = T1H;
          end else state = T0H;
        end

        T1H: begin
          if (T1H_done) begin
            state = T1L;
          end else state = T1H;
        end

        T1L: begin
          if (T1L_done) begin
            state = SHIFT;
          end else state = T1L;
        end

        T0H: begin
          if (T0H_done) begin
            state = T0L;
          end else state = T0H;
        end

        T0L: begin
          if (T0L_done) begin
            state = SHIFT;
          end else state = T0L;
        end

        SHIFT: begin
          if (k) begin
            state = RESET;
          end else state = CHECK;
        end

        RESET: begin
          if (RST_timer_done) begin
            state = LOAD;
          end else state = RESET;
        end

        default: state = START;

      endcase
    end

  end

  always @(*) begin
    case (state)
      START: begin
        T1H_s = 0;
        T1L_s = 0;
        T0H_s = 0;
        T0L_s = 0;
        RST_timer_s = 0;
        load = 0;
        sft = 0;
        DIN = 0;
      end

      LOAD: begin
        T1H_s = 0;
        T1L_s = 0;
        T0H_s = 0;
        T0L_s = 0;
        RST_timer_s = 0;
        load = 1;
        sft = 0;
        DIN = 1;
      end

      CHECK: begin
        T1H_s = 0;
        T1L_s = 0;
        T0H_s = 0;
        T0L_s = 0;
        RST_timer_s = 0;
        load = 0;
        sft = 0;
        DIN = 1;
      end

      T1H: begin
        T1H_s = 1;
        T1L_s = 0;
        T0H_s = 0;
        T0L_s = 0;
        RST_timer_s = 0;
        load = 0;
        sft = 0;
        DIN = 1; 
      end

      T1L: begin
        T1H_s = 0;
        T1L_s = 1; 
        T0H_s = 0;
        T0L_s = 0;
        RST_timer_s = 0;
        load = 0;
        sft = 0;
        DIN = 0; 
      end

      T0H: begin
        T1H_s = 0; 
        T1L_s = 0; 
        T0H_s = 1; 
        T0L_s = 0; 
        RST_timer_s = 0; 
        load = 0; 
        sft = 0; 
        DIN = 1;
      end

      T0L: begin
        T1H_s = 0; 
        T1L_s = 0; 
        T0H_s = 0; 
        T0L_s = 1; 
        RST_timer_s = 0;
        load = 0;
        sft = 0;
        DIN = 0; 
      end

      SHIFT: begin
        T1H_s = 0; 
        T1L_s = 0; 
        T0H_s = 0; 
        T0L_s = 0; 
        RST_timer_s = 0;
        load = 0;
        sft = 1;
        DIN = 0; 
      end

      RESET: begin
        T1H_s = 0; 
        T1L_s = 0; 
        T0H_s = 0; 
        T0L_s = 0; 
        RST_timer_s = 1;
        load = 0;
        sft = 0;
        DIN = 0;
      end

      default: begin
        T1H_s = 0;
        T1L_s = 0;
        T0H_s = 0;
        T0L_s = 0;
        RST_timer_s = 0;
        load = 0;
        sft = 0;
        DIN = 0;
      end

    endcase
  end

  
endmodule