module I2C (
  input clk,
  input rst,
  input init,
  input [6:0] slave_address,
  input [7:0] data,
  input wr,
  input stop,
  output wire SDA,
  output wire SCL,
  output wire done
);

  wire SDA_IN;
  wire SDA_OUT;
  wire SCL_M;
  wire add;
  wire rst_cont;
  wire out_SCL;
  wire cont_clk_s;
  wire out_rst;
  wire rst_scl_m;
  wire sft_data_rd;
  wire sft_data_wr;
  wire sft_addr;

  wire scl_m_done;
  wire scl_m_s;
  wire cont_clk_done;
  
  wire [7:0]data_wr;
  wire [6:0]addr;
  wire [2:0]bit_count;
  wire [7:0]data_rd;

  wire w_k;
  wire w_z;

  control_I2C control_I2C(
    .init(init),
    .clk(clk),
    .rst(rst),
    .SDA_IN(SDA_IN),
    .cont_clk_done(cont_clk_done),
    .scl_m_done(scl_m_done),
    .wr(wr),
    .k(w_k),
    .z(w_z),
    .stop(stop),
    .SDA_OUT(SDA_OUT),
    .SCL_M(scl_m_s),
    .add(add),
    .rst_cont(rst_cont),
    .out_SCL(out_SCL),
    .cont_clk_s(cont_clk_s),
    .out_rst(out_rst),
    .rst_scl_m(rst_scl_m),
    .sft_data_rd(sft_data_rd),
    .sft_data_wr(sft_data_wr),
    .sft_addr(sft_addr),
    .done(done)
  );

  scl_management scl_management (
    .clk(clk),
    .rst(rst_scl_m),
    .init(scl_m_s),
    .done(scl_m_done),
    .SCL_M(SCL_M)
  );

  LSR #(
    .WIDTH(8)
  ) data_wr_sft (
    .clk(clk),
    .load(out_rst),
    .sft(sft_data_wr),
    .in_B(data),
    .s_B(data_wr)
  );

  LSR #(
    .WIDTH(7)
  ) addr_sft (
    .clk(clk),
    .load(out_rst),
    .sft(sft_addr),
    .in_B(slave_address),
    .s_B(addr)
  );

  LSR_ADD #(
    .WIDTH(8)
  ) data_rd_sft (
    .clk(clk),
    .rst(out_rst),
    .sft(sft_data_rd),
    .in_B(SDA_IN),
    .s_B(data_rd)
  );

  txx #(
    .WIDTH(7),
    .TIME_COMP(7'b1000000)
  ) cont_clk (
    .clk(clk),
    .rst(rst_cont),
    .init(cont_clk_s),
    .done(cont_clk_done)
  );

  acumulador #(
    .WIDTH(3),
    .RST_VALUE(0),
    .PLUS_VALUE(1),
    .POS_EDGE(1)
  ) bit_counter (
    .clk(clk),
    .rst(rst_cont),
    .plus(add),
    .value(bit_count)
  );

  comp #(
    .WIDTH(3)
  ) comp_bit_data (
    .a(bit_count),
    .b(3'b111),
    .eq(w_k)
  );

  comp #(
    .WIDTH(3)
  ) comp_bit_addr (
    .a(bit_count),
    .b(3'b110),
    .eq(w_z)
  );

  assign SDA_IN = SDA;
  assign SDA = SDA_OUT | data_wr[7] | addr[6];
  assign SCL = out_SCL | SCL_M;

endmodule