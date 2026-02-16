module counter(
  clk,
  rst,
  init,
  data_in,
  par,
  done
);

  input clk;
  input rst;
  input init;
  input [7:0] data_in;

  output wire par;
  output wire done;

  wire w_sft;
  wire w_out_rst;
  wire w_add;
  wire w_z;
  wire w_a0;
  wire [7:0] data;

  control_counter control_counter (
    .clk(clk),
    .init(init),
    .rst(rst),
    .out_rst(w_out_rst),
    .z(w_z),
    .a0(w_a0),
    .sft(w_sft),
    .add(w_add),
    .done(done)
  );

  acumulador #(
    .WIDTH(1)
  ) acc (
    .clk(clk),
    .rst(w_out_rst),
    .plus(w_add),
    .value(par)
  );

  RSR shiftA(
    .clk(clk),
    .rst(1'b0),
    .in_DATA(data_in),
    .in_SHIFT(w_sft),
    .in_LOAD(w_out_rst),
    .out_DATA(data)
  );

  comp #(
    .WIDTH(8)
  ) compZ(
    .a(data),
    .b(8'b0),
    .eq(w_z)
  );

  comp #(
    .WIDTH(1)
  ) compA0 (
    .a(data[0]),
    .b(1'b1),
    .eq(w_a0)
  );




endmodule