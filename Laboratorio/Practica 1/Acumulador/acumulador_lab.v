module acumulador_lab(
  clk,
  rst,
  init,
  x_in,
  x_out,
  times,
  done
);
  input clk;
  input rst;
  input init;
  input [3:0] x_in;
  input [2:0] times;

  output [5:0] x_out;
  output done;

  wire w_out_rst;
  wire w_add;
  wire w_acc;
  wire w_z;
  wire [2:0] timer;
  
  acumulador #(
    .WIDTH(5)
  ) add (
    .clk(clk),
    .rst(w_out_rst),
    .PLUS_VALUE(x_in),
    .plus(w_add),
    .value(x_out)
  );

  acumulador_restando #(
    .REG_WIDTH(3)
  ) acc (
    .clk(clk),
    .rst(w_out_rst),
    .initial_value(times),
    .less(w_acc),
    .out_K(w_z)
  );
  
  control_acumulador_lab control_acumulador_lab(
    .clk(clk),
    .rst(rst),
    .init(init),
    .z(w_z),
    .out_rst(w_out_rst),
    .acc(w_acc),
    .add(w_add),
    .done(done)
  );
  
endmodule