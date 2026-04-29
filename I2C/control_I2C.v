module control_I2C (
  clk,
  init,
  rst,
  K,
  DatardM,
  SDA_IN,
  Cont_clk_done,
  SCL_done,
  WR,
  STOP,
  OE,
  SCL_Ctrl,
  out_SCL,
  SDA_OUT,
  out_rst,
  sft_data_rd,
  sft_addr,
  sft_data_wr
):
  input clk;
  input init;
  input rst;
  input K;
  input DatardM;
  input SDA_IN;
  input Cont_clk_done;
  input SCL_done;
  input WR;
  input STOP;

  output reg OE;
  output reg SCL_Ctrl;
  output reg out_SCL;
  output reg SDA_OUT;
  output reg out_rst;
  output reg sft_data_rd;
  output reg sft_addr;
  output reg sft_data_wr;





endmodule