`timescale 1ns / 1ps
module GPU_TB;
  reg clk;
  reg rst_n;

  reg reg_write = 0;
  reg [7:0] reg_px_data = 8'hFF;
  reg [5:0] reg_column = 8'd31;
  reg [5:0] reg_row = 8'd31;
  reg reg_image_palette = 0;
  reg reg_image_overlay = 0;

  wire w_write_available;

  wire [2:0] screen_RGB0;
  wire [2:0] screen_RGB1;
  wire screen_CLK;
  wire [4:0] screen_ABCDE;
  wire screen_LATCH;
  wire screen_nOE;
  GPU u_GPU (
      .clk            (clk),
      .rstn           (rst_n),
      .write          (reg_write),
      .px_data        (reg_px_data),
      .column         (reg_column),
      .row            (reg_row),
      .image_palette  (reg_image_palette),
      .image_overlay  (reg_image_overlay),
      .write_available(w_write_available),
      .to_screen_RGB0 (screen_RGB0),
      .to_screen_RGB1 (screen_RGB1),
      .to_screen_CLK  (screen_CLK),
      .to_screen_ABCDE(screen_ABCDE),
      .to_screen_LATCH(screen_LATCH),
      .to_screen_nOE  (screen_nOE)
  );


  localparam CLK_PERIOD = 40;
  always #(CLK_PERIOD / 2) clk = ~clk;

  initial begin
    $dumpfile("GPU_TB.vcd");
    $dumpvars(0, GPU_TB);
  end

  initial begin
    #1 rst_n <= 1'bx;
    clk <= 1'bx;
    #(CLK_PERIOD * 3) rst_n <= 1;
    #(CLK_PERIOD * 3) rst_n <= 0;
    clk <= 0;
    repeat (5) @(posedge clk);
    rst_n <= 1;
    @(negedge clk);
    //repeat (10) @(negedge clk);
    while (!w_write_available) begin
      @(negedge clk);
    end
    reg_px_data = 8'h12;
    reg_write = 1;
    @(negedge clk);
    reg_write = 0;
    #(CLK_PERIOD * 100_000) $finish(2);
  end

endmodule
