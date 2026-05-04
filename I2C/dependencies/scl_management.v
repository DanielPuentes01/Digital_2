module scl_management (
    clk,
    rst,
    init,
    done,
    SCL_M
);

  input clk;
  input rst;
  input init;

  output wire done;
  output wire SCL_M;

  wire cont_clk_s;
  wire rst_cont_clk;
  wire cont_clk_done;

  control_scl_management control_scl_management (
    .clk(clk),
    .rst(rst),
    .init(init),
    .done(done),
    .SCL_M(SCL_M),
    .out_rst(rst_cont_clk),
    .cont_clk_s(cont_clk_s),
    .cont_clk_done(cont_clk_done)
  );

  txx #(
    .WIDTH(7),
    .TIME_COMP(7'b1000000)
  ) cont_clk (
    .clk(clk),
    .rst(rst_cont_clk),
    .init(cont_clk_s),
    .done(cont_clk_done)
  );
  





endmodule