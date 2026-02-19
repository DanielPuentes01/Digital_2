module transmisor_serial(
  clk,
  rst,
  init,
  data_in,
  tx,
  busy,
  done
);
  input clk;
  input rst;
  input init;
  input [7:0] data_in;

  output wire tx;
  output wire busy;
  output wire done;

  wire w_load;
  wire w_add_tick;
  wire w_add_bit;
  wire w_z;
  wire w_k;
  wire w_out_rst;

  parameter CLKS_PER_BIT = 4'b1000;

  control_transmisor_serial control_transmisor_serial(
    .clk(clk),
    .rst(rst),
    .init(init),
    .z(w_z),
    .k(w_k),
    .out_rst(w_out_rst),
    .busy(busy),
    .done(done),
    .load(w_load),
    .add_tick(w_add_tick),
    .add_bit(w_add_bit)
  );

  rsr data(
    .clk(clk),
    .rst(w_out_rst),
    .init(w_load),
    .data_in(data_in),
    .sft(w_add_bit),
    .data_out(tx)
  );

  acumulador_restando #(
    .REG_WIDTH(4)
  ) acc_z ( 
    .clk(clk),
    .rst(w_add_bit | rst),
    .initial_value(CLKS_PER_BIT - 1),
    .less(w_add_tick),
    .out_K(w_z)
  );

  acumulador_restando #(
    .REG_WIDTH(4)
  ) acc_k(
    .clk(clk),
    .rst(rst),
    .initial_value(4'b1000),
    .less(w_add_bit),
    .out_K(w_k)
  );


endmodule