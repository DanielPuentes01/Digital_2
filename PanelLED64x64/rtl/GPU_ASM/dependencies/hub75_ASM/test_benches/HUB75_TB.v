module HUB75_TB;
  reg clk;
  reg rst_n;

  wire [2:0] w_RGB0;
  wire [2:0] w_RGB1;
  wire w_S_CLK;
  wire [4:0] w_ABCDE;
  wire w_LATCH;
  wire w_nOE;
  HUB75 u_HUB75 (
      .clk           (clk),
      .rstn          (rst_n),
      .w_RGB0        (w_RGB0),
      .w_RGB1        (w_RGB1),
      .w_SCREEN_CLOCK(w_S_CLK),
      .ABCDE         (w_ABCDE),
      .LATCH         (w_LATCH),
      .nOE           (w_nOE)
  );

  localparam CLK_PERIOD = 10;
  always #(CLK_PERIOD / 2) clk = ~clk;

  initial begin
    $dumpfile("HUB75_TB.vcd");
    $dumpvars(0, HUB75_TB);
  end

  initial begin
    #1 rst_n <= 1'bx;
    clk <= 1'bx;
    #(CLK_PERIOD * 3) rst_n <= 1;
    #(CLK_PERIOD * 3) rst_n <= 0;
    clk <= 0;
    repeat (5) @(posedge clk);
    rst_n <= 1;
    @(posedge clk);
    repeat (10) @(posedge clk);
    #(CLK_PERIOD * 3) rst_n <= 1;
    #(CLK_PERIOD * 3) rst_n <= 0;
    repeat (5) @(posedge clk);
    rst_n <= 1;
    @(posedge clk);
    repeat (200) @(posedge clk);
    $finish(2);
  end

endmodule
