module latch_command #(
  parameter n_bits_comando = 3,
  parameter n_ciclos_comando = 4
) (
  input clk,
  input rst,
  input init,
  output wire latch,
  output wire w_clk,
  output wire done
);

  wire rst_cont_clk;
  wire [n_bits_comando-1:0] cont_clk;
  wire add_cont_clk;
  wire cont_clk_done;

  localparam [n_bits_comando-1:0] N_CICLOS = n_ciclos_comando;

  control_latch_command control_latch_command(
    .clk(clk),
    .rst(rst),
    .init(init),
    .cont_clk_done(cont_clk_done),
    .latch(latch),
    .w_clk(w_clk),
    .add_cont_clk(add_cont_clk),
    .rst_cont_clk(rst_cont_clk),
    .done(done)
  );

  acumulador #(.WIDTH(n_bits_comando), .RST_VALUE(0)) acc_cont_clk(
    .clk(clk),
    .rst(rst_cont_clk),
    .plus(add_cont_clk),
    .value(cont_clk)
  );

  comp #(.WIDTH(n_bits_comando)) comp_cont_clk(
    .a(cont_clk),
    .b(N_CICLOS),
    .eq(cont_clk_done)
  );

endmodule