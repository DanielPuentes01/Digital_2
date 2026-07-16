`timescale 1ns / 1ps
module DEMO_GPU_TB;
  reg clk;
  reg rst_n;

  wire [2:0] wire_to_screen_RGB0;
  wire [2:0] wire_to_screen_RGB1;
  wire wire_to_screen_CLK;
  wire [4:0] wire_to_screen_ABCDE;
  wire wire_to_screen_LATCH;
  wire wire_to_screen_nOE;


  DEMO_GPU u_DEMO_GPU (
      .clk                 (clk),
      .rstn                (rst_n),
      .wire_to_screen_RGB0 (wire_to_screen_RGB0),
      .wire_to_screen_RGB1 (wire_to_screen_RGB1),
      .wire_to_screen_CLK  (wire_to_screen_CLK),
      .wire_to_screen_ABCDE(wire_to_screen_ABCDE),
      .wire_to_screen_LATCH(wire_to_screen_LATCH),
      .wire_to_screen_nOE  (wire_to_screen_nOE)
  );



  localparam CLK_PERIOD = 40;
  always #(CLK_PERIOD / 2) clk = ~clk;

  initial begin
    $dumpfile("DEMO_GPU_TB.vcd");
    $dumpvars(0, DEMO_GPU_TB);
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
    repeat (10_000) @(posedge clk);
    $finish(2);
  end

endmodule
