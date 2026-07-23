module div_32 (
    input clk,
    input rst,
    input init_in,
    input [31:0] A,
    input [31:0] B,
    output wire [31:0] R,  //resto
    output wire [31:0] Q,  //coeficiente
    output done
);



  wire w_ctl_rst, w_shift, w_load_R, w_decrement, w_K;
  wire [16:0] R_Sub;

  lsr_div u_lsr_div (
      .clk   (clk),
      .rst   (w_ctl_rst),
      .base_A(A),
      .shift (w_shift),
      .new_R (R_Sub),
      .load_R(w_load_R),
      .R     (R),          //resto
      .Q     (Q)           //coeficiente
  );


  sumador #(
      .N_BITS(17),
      .CP2(1)
  ) resta (
      .A(R),
      .B(B),
      .out_SUM(R_Sub)
  );

  acumulador_restando #(
      .REG_WIDTH (5),
      .RST_VALUE (16),
      .LESS_VALUE(1)
  ) n_terminos (
      .rst  (w_ctl_rst),
      .clk  (clk),
      .less (w_decrement),
      .out_K(w_K)
  );

  control_div u_control_div (
      .clk      (clk),
      .rst      (rst),
      .init_    (init_in),
      .R_B_MSB  (R_Sub[16]),
      .in_K     (w_K),
      .ctl_rst  (w_ctl_rst),
      .load_R   (w_load_R),
      .shift    (w_shift),
      .decrement(w_decrement),
      .DONE     (done)
  );

endmodule


