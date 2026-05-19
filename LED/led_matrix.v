module led_matrix (
  clk,
  init,
  rst,
  DIN
);

  input clk;
  input init;
  input rst;

  reg [23:0] mem [0:63];

  output wire DIN;

  initial begin
    $readmemh("led_matrix.mem", mem);
  end

  wire led_s;
  wire led_done;
  wire RST_TIMER_s;
  wire RST_TIMER_done;
  wire add;
  wire rst_cont;
  wire load_color;
  wire [6:0] cont;
  wire z;

  control_led_matrix control_led_matrix (
    .clk(clk),
    .rst(rst),
    .init(1),
    .RST_TIMER_s(RST_TIMER_s),
    .RST_TIMER_done(RST_TIMER_done),
    .z(z),
    .led_s(led_s),
    .led_done(led_done),
    .add(add),
    .rst_cont(rst_cont),
    .load_color(load_color)
  );

  led led (
    .clk(clk),
    .rst(load_color),
    .init(led_s),
    .Color_in(mem[cont]),
    .DIN(DIN),
    .done(led_done)
  );

  acumulador #(
    .WIDTH(7)
  ) cont_acc (
    .clk(clk),
    .rst(rst_cont),
    .plus(add),
    .value(cont)
  );

  comp #(
    .WIDTH(7)
  ) comparador (
    .a(cont),
    .b(7'b1000000),
    .eq(z)
  );

  txx #(
      .WIDTH(12),
      .TIME_COMP(12'b100111000100)
  ) RST_timer (
      .clk(clk),
      .rst(rst),
      .init(RST_TIMER_s),
      .done(RST_TIMER_done)
  ); 

endmodule
