module sendcfg #(
  parameter CFG_DATA = 16'h0000,
  parameter n_CHIPS = 5'd8
) (
  input clk,
  input rst,
  input init,
  output wire done,
  output wire [2:0] out_RGB,
  output wire w_clk
);

  wire rst_cont_cfg;
  wire rst_cfg_reg;
  wire rst_cont_chip;
  wire shift_cfg;
  wire add_cont_chip;
  wire load_cfg_reg;
  wire cont_cfg_done;
  wire cont_chip_done;
  wire [4:0] cont_cfg;
  wire [4:0] cont_chip;
  wire [15:0] cfg_data_reg;

  control_sendcfg control_sendcfg(
    .clk(clk),
    .rst(rst),
    .init(init),
    .cont_cfg_done(cont_cfg_done),
    .cont_chip_done(cont_chip_done),
    .rst_cont_cfg(rst_cont_cfg),
    .rst_cfg_reg(rst_cfg_reg),
    .rst_cont_chip(rst_cont_chip),
    .shift_cfg(shift_cfg),
    .add_cont_chip(add_cont_chip),
    .load_cfg_reg(load_cfg_reg),
    .w_clk(w_clk),
    .done(done)
  );
  
  RSR #(.WIDTH(16)) RSR(
    .clk(clk),
    .in_B(CFG_DATA),
    .sft(shift_cfg),
    .load(rst_cfg_reg),
    .s_B(cfg_data_reg)
  );

  acumulador #(.WIDTH(5), .RST_VALUE(0)) acc_cont_cfg(
    .clk(clk),
    .rst(rst_cont_cfg),
    .plus(shift_cfg),
    .value(cont_cfg)
  );

  comp #(.WIDTH(5)) comp_cont_cfg(
    .a(cont_cfg),
    .b(5'd16),
    .eq(cont_cfg_done)
  );

  acumulador #(.WIDTH(5), .RST_VALUE(0)) acc_cont_chip(
    .clk(clk),
    .rst(rst_cont_chip),
    .plus(add_cont_chip),
    .value(cont_chip)
  );
  comp #(.WIDTH(5)) comp_cont_chip(
    .a(cont_chip),
    .b(n_CHIPS),
    .eq(cont_chip_done)
  );

  assign out_RGB = {3{cfg_data_reg[0]}};


endmodule