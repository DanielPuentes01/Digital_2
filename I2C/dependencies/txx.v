module txx #(
  parameter WIDTH = 11,
  parameter [WIDTH-1:0] TIME_COMP = (1'b1 << (WIDTH-1))
)(
    clk,
    rst,
    init,
    done
);

  input clk;
  input rst;
  input init;


  wire [WIDTH-1:0] cont_cursor;
  wire plus;
  wire rst_add;
  wire w_k;


  output wire done;


  acumulador #(
      .WIDTH(WIDTH),
      .RST_VALUE(0),
      .PLUS_VALUE(1),
      .POS_EDGE(1)
  ) contador (
      .clk  (clk),
      .rst  (rst_add),
      .plus (plus),
      .value(cont_cursor)
  );

  comp #(
      .WIDTH(WIDTH)
  ) comparador (
      .a(cont_cursor),
      .b(TIME_COMP),
      .eq(w_k)
  );

  control_txx control_txx (
      .clk(clk),
      .rst(rst),
      .init(init),
      .k(w_k),
      .done(done),
      .plus(plus),
      .out_rst(rst_add)
  );


endmodule
