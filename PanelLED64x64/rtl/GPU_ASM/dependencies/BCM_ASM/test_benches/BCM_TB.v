`timescale 1ns / 1ps
`define SIMULATION
module BCM_TB;
  reg  clk;
  reg  rst;
  reg  INIT = 0;
  reg  CONTINUE = 0;
  wire w_NEXT_PLANE;
  wire w_FINISH;
  BCM u_BCM (
      .clk           (clk),
      .rst           (rst),
      .in_INIT       (INIT),
      .in_CONTINUE   (CONTINUE),
      .out_NEXT_PLANE(w_NEXT_PLANE),
      .out_FINISH    (w_FINISH)
  );

  localparam CLK_PERIOD = 40;
  always #(CLK_PERIOD / 2) clk = ~clk;

  initial begin
    $dumpfile("BCM_TB.vcd");
    $dumpvars(0, BCM_TB);
  end

  initial begin
    #1 rst <= 1'bx;
    clk <= 1'bx;
    #(CLK_PERIOD * 3) rst <= 0;
    #(CLK_PERIOD * 3) rst <= 1;
    clk <= 0;
    repeat (5) @(posedge clk);
    rst <= 0;
    repeat (2) @(posedge clk);
    INIT <= 1;
    repeat (2) @(posedge clk);
    INIT <= 0;
    repeat (514) @(posedge clk);
    CONTINUE <= 1;
    repeat (2) @(posedge clk);
    CONTINUE <= 0;
    repeat (1027) @(posedge clk);
    CONTINUE <= 1;
    repeat (2) @(posedge clk);
    CONTINUE <= 0;
    repeat (2051) @(posedge clk);
    CONTINUE <= 1;
    repeat (2) @(posedge clk);
    CONTINUE <= 0;
    repeat (5000) @(posedge clk);
    CONTINUE <= 1;
    repeat (2) @(posedge clk);
    CONTINUE <= 0;
    $finish(2);
  end

endmodule
