module send_frame (
  input clk,
  input rst,
  input init,
  input vsync_done,
  output wire latch,
  output wire OE,
  output wire w_clk,
  output wire [2:0] RGB1,
  output wire [2:0] RGB2,
  output wire done,
  output wire cont_row_done_w,
  output wire [5:0] cont_ABCDE,
  output wire [5:0] cont_row
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
  wire rst_cont_row;
  wire add_cont_clk;
  wire add_cont_row;
  wire rst_cont_clk;
  wire rst_cont_prio;
  wire w_clk_control;
  wire w_clk_latch;
  wire start_4_clk;
  wire f_clk_done;
  wire cont_row_done;

  wire [7:0] cont_col;
  wire [6:0] cont_clk;
  wire [4:0] cont_prio;

  wire OE_4clk;
  wire OEctrl;

  assign cont_row_done_w = cont_row_done;

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
    .cont_row_done(cont_row_done),
    .data_latch_done(data_latch_done),
    .data_latch(data_latch),
    .w_clk(w_clk_control),
    .vsync_done(vsync_done),
    .add_cont_col(add_cont_col),
    .add_cont_row(add_cont_row),
    .load_RGB(load_RGB),
    .add_cont_prio(add_cont_prio),
    .OE(OEctrl),
    .add_ABCDE(add_ABCDE),
    .start_4_clk(start_4_clk),
    .f_clk_done(f_clk_done),
    .rst_cont_ABCDE(rst_cont_ABCDE),
    .rst_cont_col(rst_cont_col),
    .rst_cont_row(rst_cont_row),
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

  four_clk four_clk(
    .clk   (clk   ),
    .rst   (rst   ),
    .init  (start_4_clk  ),
    .w_clk (OE_4clk ),
    .done  (f_clk_done  )
  );

  acumulador_restando #(.REG_WIDTH(8)) acc_cont_col(
    .clk(clk),
    .rst(rst_cont_col),
    .initial_value(128),
    .less(add_cont_col),
    .out_K(cont_col)
  );

  comp #(.WIDTH(8)) comp_cont_col(
    .a(cont_col),
    .b(0),
    .eq(cont_col_done)
  );

  acumulador #(.WIDTH(6), .RST_VALUE(0)) acc_cont_row(
    .clk(clk),
    .rst(rst_cont_row),
    .plus(add_cont_row),
    .value(cont_row)
  );

  comp #(.WIDTH(6)) comp_cont_row(
    .a(cont_row),
    .b(6'd32),
    .eq(cont_row_done)
  );

  acumulador #(.WIDTH(7), .RST_VALUE(0)) acc_cont_clk(
    .clk(clk),
    .rst(rst_cont_clk),
    .plus(add_cont_clk),
    .value(cont_clk)
  );

  comp #(.WIDTH(7)) comp_cont_clk(
    .a(cont_clk),
    .b(7'd70),
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

  multiplexor2x1 #(.IN_WIDTH(1)) muxOE(
    .IN1(OE_4clk),
    .IN0(OEctrl),
    .SELECT(start_4_clk),
    .MUX_OUT(OE)
  );
  

  pixel_reader #(
  ) pixel_reader (
    .clk(clk),
    .col(cont_col-1),
    .row(cont_row),
    .plane(cont_prio),
    .we(framebuffer_we),
    .wr_addr(framebuffer_addr),
    .wr_data(framebuffer_data),
    .RGB1(RGB1),
    .RGB2(RGB2)
  );



endmodule