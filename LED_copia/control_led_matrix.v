module control_led_matrix (
  clk,
  rst,
  init,
  RST_TIMER_s,
  RST_TIMER_done,
  z,
  led_s,
  led_done,
  add,
  rst_cont,
  load_color
);

  input clk;
  input rst;
  input init;
  input RST_TIMER_done;
  input z;
  input led_done;

  output reg RST_TIMER_s;
  output reg led_s;
  output reg add;
  output reg rst_cont;
  output reg load_color;

  reg [2:0] state;
  parameter START = 3'b000;
  parameter LOAD = 3'b001;
  parameter LED = 3'b010;
  parameter CONT = 3'b011;
  parameter RST_TIMER = 3'b100;
  parameter DONE = 3'b101;

  always @(posedge clk) begin
    if (rst) begin
      state = START;
    end else begin
      case (state)
        START: state = init ? LOAD : START; 
        LOAD: state = LED;
        LED: state = led_done ? CONT : LED;
        CONT: state = z ? RST_TIMER : LOAD;
        RST_TIMER: state = RST_TIMER_done ? DONE : RST_TIMER;
        DONE: state = LOAD;
        default: state = START;
      endcase
    end
  end
  
  always @(*) begin
    case (state)
      START: begin
        RST_TIMER_s = 0;
        led_s = 0;
        add = 0;
        rst_cont = 1;
        load_color = 0;
      end
      LOAD: begin
        RST_TIMER_s = 0;
        led_s = 0;
        add = 0;
        rst_cont = 0;
        load_color = 1;
      end
      LED: begin
        RST_TIMER_s = 0;
        led_s = 1;
        add = 0;
        rst_cont = 0;
        load_color = 0;
      end
      CONT: begin
        RST_TIMER_s = 0;
        led_s = 0;
        add = 1;
        rst_cont = 0;
        load_color = 0;
      end
      RST_TIMER: begin
        RST_TIMER_s = 1;
        led_s = 0;
        add = 0;
        rst_cont = 0;
        load_color = 0;
      end
      DONE: begin
        RST_TIMER_s = 0;
        led_s = 0;
        add = 0;
        rst_cont = 1;  
        load_color = 0;      
      end
    endcase
  end
endmodule