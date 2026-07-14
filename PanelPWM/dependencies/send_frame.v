module send_frame (
  input clk,
  input rst,
  input init,
  output wire latch,
  output wire OE,
  output wire w_clk,
  output wire [2:0] RGB1,
  output wire [2:0] RGB2,
  output wire done,
  output wire [5:0] cont_ABCDE
);

  wire cont_clk_done;
  wire cont_prio_done;
  wire cont_ABCDE_done;
  wire cont_col_done;
  wire data_latch;
  wire add_cont_col;
  wire data_latch_done;
  wire load_RGB;
  wire add_cont_prio;
  wire add_ABCDE;
  wire rst_cont_ABCDE;
  wire rst_cont_col;
  wire add_cont_clk;
  wire rst_cont_clk;
  wire rst_cont_prio;
  wire w_clk_control;
  wire w_clk_latch;

  wire [7:0] cont_col;
  wire [6:0] cont_clk;
  
  wire [4:0] cont_prio;

  //framebuffer signals (TEMPORAL)

  wire framebuffer_we;
  wire [12:0] framebuffer_addr;
  wire [47:0] framebuffer_data;

  assign framebuffer_we   = 1'b0;
  assign framebuffer_addr = 13'd0;
  assign framebuffer_data = 0;



  control_send_frame control_send_frame(
    .clk(clk),
    .rst(rst),
    .init(init),
    .cont_clk_done(cont_clk_done),
    .cont_prio_done(cont_prio_done),
    .cont_ABCDE_done(cont_ABCDE_done),
    .cont_col_done(cont_col_done),
    .data_latch_done(data_latch_done),
    .data_latch(data_latch),
    .w_clk(w_clk_control),
    .add_cont_col(add_cont_col),
    .load_RGB(load_RGB),
    .add_cont_prio(add_cont_prio),
    .OE(OE),
    .add_ABCDE(add_ABCDE),
    .rst_cont_ABCDE(rst_cont_ABCDE),
    .rst_cont_col(rst_cont_col),
    .add_cont_clk(add_cont_clk),
    .rst_cont_clk(rst_cont_clk),
    .rst_cont_prio(rst_cont_prio),
    .done(done) 
  );

  latch_command #(
    .n_bits_comando(1),
    .n_ciclos_comando(1)
  ) latch_command(
    .clk(clk),
    .rst(rst),
    .init(data_latch),
    .latch(latch),
    .w_clk(w_clk_latch),
    .done(data_latch_done)
  );

  acumulador #(.WIDTH(8), .RST_VALUE(0)) acc_cont_col(
    .clk(clk),
    .rst(rst_cont_col),
    .plus(add_cont_col),
    .value(cont_col)
  );

  comp #(.WIDTH(8)) comp_cont_col(
    .a(cont_col),
    .b(8'd128),
    .eq(cont_col_done)
  );

  acumulador #(.WIDTH(7), .RST_VALUE(0)) acc_cont_clk(
    .clk(clk),
    .rst(rst_cont_clk),
    .plus(add_cont_clk),
    .value(cont_clk)
  );

  comp #(.WIDTH(7)) comp_cont_clk(
    .a(cont_clk),
    .b(7'd74),
    .eq(cont_clk_done)
  );

  acumulador #(.WIDTH(5), .RST_VALUE(0)) acc_cont_prio(
    .clk(clk),
    .rst(rst_cont_prio),
    .plus(add_cont_prio),
    .value(cont_prio)
  );

  comp #(.WIDTH(5)) comp_cont_prio(
    .a(cont_prio),
    .b(5'b10000),
    .eq(cont_prio_done)
  );

  acumulador #(.WIDTH(6), .RST_VALUE(0)) acc_cont_ABCDE(
    .clk(clk),
    .rst(rst_cont_ABCDE),
    .plus(add_ABCDE),
    .value(cont_ABCDE)
  );

  comp #(.WIDTH(6)) comp_cont_ABCDE(
    .a(cont_ABCDE),
    .b(6'd32),
    .eq(cont_ABCDE_done)
  );


  multiplexor2x1 #(.IN_WIDTH(1)) mux_w_clk(
    .IN1(w_clk_latch),
    .IN0(w_clk_control),
    .SELECT(data_latch),
    .MUX_OUT(w_clk)
  );

  pixel_reader #(
  ) pixel_reader (
    .clk(clk),
    .col(cont_col),
    .row(cont_ABCDE),
    .plane(cont_prio),
    .we(framebuffer_we),
    .wr_addr(framebuffer_addr),
    .wr_data(framebuffer_data),
    .RGB1(RGB1),
    .RGB2(RGB2)
  );



endmodule