module led (
  clk,
  rst,
  init,
  Color_in,
  DIN,
  done
);

  input clk;
  input rst;
  input init;
  input [23:0] Color_in;

  output wire DIN;
  output wire done;
  wire T1H_done;
  wire T1L_done;
  wire T0H_done;
  wire T0L_done;
  wire T1H_s;
  wire T1L_s;
  wire T0H_s;
  wire T0L_s;
  wire k;
  wire load;
  wire sft;
  wire [23:0] color;
  wire [4:0] cont;

  control_led control_led (
    .clk(clk),
    .rst(rst),
    .init(init),
    .T1H_done(T1H_done),
    .T1L_done(T1L_done),
    .T0H_done(T0H_done),
    .T0L_done(T0L_done),
    .MSBColor(color[23]),
    .T1H_s(T1H_s),
    .T1L_s(T1L_s),
    .T0H_s(T0H_s),
    .T0L_s(T0L_s),
    .done(done),
    .k(k),
    .load(load),
    .sft(sft),
    .DIN(DIN)
  ); 
  
  LSR #(
      .WIDTH(24)
  ) registro (
      .clk(clk),
      .in_B(Color_in),
      .sft(sft),
      .load(load),
      .s_B(color)
  );

  txx #(
      .WIDTH(5),
      .TIME_COMP(5'b10100)
  ) T1H (
      .clk(clk),
      .rst(rst),
      .init(T1H_s),
      .done(T1H_done)
  );

  txx #(
      .WIDTH(4),
      .TIME_COMP(4'b1100)
  ) T1L (
      .clk(clk),
      .rst(rst),
      .init(T1L_s),
      .done(T1L_done)
  );

  txx #(
      .WIDTH(4),
      .TIME_COMP(4'b1010)
  ) T0H (
      .clk(clk),
      .rst(rst),
      .init(T0H_s),
      .done(T0H_done)
  );

  txx #(
      .WIDTH(5),
      .TIME_COMP(5'b10110)
  ) T0L (
      .clk(clk),
      .rst(rst),
      .init(T0L_s),
      .done(T0L_done)
  );

  acumulador #(
      .WIDTH(5),
      .RST_VALUE(0),
      .PLUS_VALUE(1),
      .POS_EDGE(1)
  ) contador (
      .clk  (clk),
      .rst  (rst | done),
      .plus (sft),
      .value(cont)
  );

  comp #(
      .WIDTH(5)
  ) comparador (
      .a(cont),
      .b(5'b11000),
      .eq(k)
  );



endmodule
