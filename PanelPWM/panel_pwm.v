module panel_pwm (
  input init,
  input clk,
  input rst,
  output wire [2:0] RGB1,
  output wire [2:0] RGB2,
  output wire OE,
  output wire w_clk,
  output wire latch,
  output wire [4:0] ABCDE,
  output wire done
);

  wire pre_acts;
  wire en_op;
  wire wrcfg1;
  wire wrcfg2;
  wire wrcfg3;
  wire wrcfg4;
  wire sendcfg1_s;
  wire sendcfg2_s;
  wire sendcfg3_s;
  wire sendcfg4_s;
  wire vsync;
  wire f_clk;
  wire set_color;

  wire pre_acts_done;
  wire en_op_done;
  wire wrcfg1_done;
  wire wrcfg2_done;
  wire wrcfg3_done;
  wire wrcfg4_done;
  wire sendcfg1_done;
  wire sendcfg2_done;
  wire sendcfg3_done;
  wire sendcfg4_done;
  wire vsync_done;
  wire f_clk_done;
  wire send_frame_done;

  wire latch_pre_acts;
  wire latch_en_op;
  wire latch_wr_cfg_1;
  wire latch_wr_cfg_2;
  wire latch_wr_cfg_3;
  wire latch_wr_cfg_4;
  wire latch_vsync;
  wire latch_send_color;

  wire [2:0] RGB_send_cfg_1;
  wire [2:0] RGB_send_cfg_2;
  wire [2:0] RGB_send_cfg_3;
  wire [2:0] RGB_send_cfg_4;
  wire [2:0] RGB1_send_color;
  wire [2:0] RGB2_send_color;

  wire clk_pre_acts;
  wire clk_en_op;
  wire clk_wr_cfg_1;
  wire clk_wr_cfg_2;
  wire clk_wr_cfg_3;
  wire clk_wr_cfg_4;
  wire clk_vsync;
  wire clk_sendcfg1;
  wire clk_sendcfg2;
  wire clk_sendcfg3;
  wire clk_sendcfg4;
  wire clk_f_clk;
  wire clk_send_color;

  wire oe_send_frame;

  control_panel_pwm control_panel_pwm(
    .clk            (clk            ),
    .rst            (rst            ),
    .init           (init           ),
    .pre_acts_done  (pre_acts_done  ),
    .en_op_done     (en_op_done     ),
    .wrcfg1_done    (wrcfg1_done    ),
    .wrcfg2_done    (wrcfg2_done    ),
    .wrcfg3_done    (wrcfg3_done    ),
    .wrcfg4_done    (wrcfg4_done    ),
    .sendcfg1_done  (sendcfg1_done  ),
    .sendcfg2_done  (sendcfg2_done  ),
    .sendcfg3_done  (sendcfg3_done  ),
    .sendcfg4_done  (sendcfg4_done  ),
    .vsync_done     (vsync_done     ),
    .f_clk_done     (f_clk_done     ),
    .set_color_done (send_frame_done ),
    .pre_acts       (pre_acts       ),
    .en_op          (en_op          ),
    .wrcfg1         (wrcfg1         ),
    .wrcfg2         (wrcfg2         ),
    .wrcfg3         (wrcfg3         ),
    .wrcfg4         (wrcfg4         ),
    .sendcfg1       (sendcfg1_s       ),
    .sendcfg2       (sendcfg2_s       ),
    .sendcfg3       (sendcfg3_s       ),
    .sendcfg4       (sendcfg4_s       ),
    .vsync          (vsync          ),
    .set_color      (set_color      ),
    .f_clk          (f_clk          ),
    .done           (done           )
  );

  latch_command #(
    .n_bits_comando(3'd4),
    .n_ciclos_comando(4'd14)
  )
  PRE_ACT_COMMAND(
    .clk   (clk   ),
    .rst   (rst   ),
    .init  (pre_acts  ),
    .latch (latch_pre_acts),
    .w_clk (clk_pre_acts ),
    .done  (pre_acts_done  )
  );

  latch_command #(
    .n_bits_comando(3'd4),
    .n_ciclos_comando(4'd12)
  )
  EN_OP_COMMAND(
    .clk   (clk   ),
    .rst   (rst   ),
    .init  (en_op  ),
    .latch (latch_en_op),
    .w_clk (clk_en_op ),
    .done  (en_op_done  )
  );

  latch_command #(
    .n_bits_comando(2'd3),
    .n_ciclos_comando(3'd4)
  )
  WR_CFG_1_COMMAND(
    .clk   (clk   ),
    .rst   (rst   ),
    .init  (wrcfg1  ),
    .latch (latch_wr_cfg_1),
    .w_clk (clk_wr_cfg_1 ),
    .done  (wrcfg1_done  )
  );

  latch_command #(
    .n_bits_comando(2'd3),
    .n_ciclos_comando(3'd6)
  )
  WR_CFG_2_COMMAND(
    .clk   (clk   ),
    .rst   (rst   ),
    .init  (wrcfg2  ),
    .latch (latch_wr_cfg_2),
    .w_clk (clk_wr_cfg_2 ),
    .done  (wrcfg2_done  )
  );

  latch_command #(
    .n_bits_comando(3'd4),
    .n_ciclos_comando(4'd8)
  )
  WR_CFG_3_COMMAND(
    .clk   (clk   ),
    .rst   (rst   ),
    .init  (wrcfg3  ),
    .latch (latch_wr_cfg_3),
    .w_clk (clk_wr_cfg_3 ),
    .done  (wrcfg3_done  )
  );

  latch_command #(
    .n_bits_comando(3'd4),
    .n_ciclos_comando(4'd10)
  )
  WR_CFG_4_COMMAND(
    .clk   (clk   ),
    .rst   (rst   ),
    .init  (wrcfg4  ),
    .latch (latch_wr_cfg_4),
    .w_clk (clk_wr_cfg_4 ),
    .done  (wrcfg4_done  )
  );

  latch_command #(
    .n_bits_comando(2'd2),
    .n_ciclos_comando(2'd3)
  )
  VSYNC_COMMAND(
    .clk   (clk   ),
    .rst   (rst   ),
    .init  (vsync  ),
    .latch (latch_vsync),
    .w_clk (clk_vsync ),
    .done  (vsync_done  )
  );

  sendcfg #(.CFG_DATA(16'h7E08))
  SENDCFG1(
    .clk     (clk     ),
    .rst     (rst     ),
    .init    (sendcfg1_s    ),
    .done    (sendcfg1_done    ),
    .out_RGB (RGB_send_cfg_1 ),
    .w_clk   (clk_sendcfg1   )
  );

  sendcfg #(.CFG_DATA(16'h0FB0))
  SENDCFG2(
    .clk     (clk     ),
    .rst     (rst     ),
    .init    (sendcfg2_s    ),
    .done    (sendcfg2_done    ),
    .out_RGB (RGB_send_cfg_2 ),
    .w_clk   (clk_sendcfg2   )
  );

  sendcfg #(.CFG_DATA(16'hE79D))
  SENDCFG3(
    .clk     (clk     ),
    .rst     (rst     ),
    .init    (sendcfg3_s    ),
    .done    (sendcfg3_done    ),
    .out_RGB (RGB_send_cfg_3 ),
    .w_clk   (clk_sendcfg3   )
  );

  sendcfg #(.CFG_DATA(16'h60B6))
  SENDCFG4(
    .clk     (clk     ),
    .rst     (rst     ),
    .init    (sendcfg4_s    ),
    .done    (sendcfg4_done    ),
    .out_RGB (RGB_send_cfg_4 ),
    .w_clk   (clk_sendcfg4   )
  );

  four_clk four_clk(
    .clk   (clk   ),
    .rst   (rst   ),
    .init  (f_clk  ),
    .w_clk (clk_f_clk ),
    .done  (f_clk_done  )
  );

  send_frame #(.n_bits_color(1))
  u_send_frame(
    .clk        (clk        ),
    .rst        (rst        ),
    .init       (set_color  ),
    .latch      (latch_send_color),
    .OE         (oe_send_frame         ),
    .w_clk      (clk_send_color     ),
    .RGB1       (RGB1_send_color       ),
    .RGB2       (RGB2_send_color       ),
    .done       (send_frame_done       ),
    .cont_ABCDE (ABCDE )
  );

  assign w_clk = clk_pre_acts | clk_en_op | clk_wr_cfg_1 | clk_wr_cfg_2 | clk_wr_cfg_3 | clk_wr_cfg_4 | clk_sendcfg1 | clk_sendcfg2 | clk_sendcfg3 | clk_sendcfg4 | clk_vsync | clk_f_clk | clk_send_color;
  
  assign RGB1 =
    sendcfg1_s ? RGB_send_cfg_1 :
    sendcfg2_s ? RGB_send_cfg_2 :
    sendcfg3_s ? RGB_send_cfg_3 :
    sendcfg4_s ? RGB_send_cfg_4 :
    set_color ? RGB1_send_color :
    3'b000;
  
  assign RGB2 =
    sendcfg1_s ? RGB_send_cfg_1 :
    sendcfg2_s ? RGB_send_cfg_2 :
    sendcfg3_s ? RGB_send_cfg_3 :
    sendcfg4_s ? RGB_send_cfg_4 :
    set_color ? RGB2_send_color :
    3'b000;

  assign latch = latch_pre_acts | latch_en_op | latch_wr_cfg_1 | latch_wr_cfg_2 | latch_wr_cfg_3 | latch_wr_cfg_4 | latch_vsync | latch_send_color;

  assign OE = set_color ? oe_send_frame : 1'b1;

endmodule