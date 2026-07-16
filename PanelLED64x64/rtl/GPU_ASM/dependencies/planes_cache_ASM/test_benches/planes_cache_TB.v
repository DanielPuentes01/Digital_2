`timescale 1ns / 100ps

module planes_cache_TB;
  integer i;
  reg clk;
  reg [63:0] R = 64'h0123ABCD;
  reg [63:0] G = 64'h0123ABCD;
  reg [63:0] B = 64'h0123ABCD;
  reg LOAD0;
  reg LOAD1;
  reg SHIFT;
  wire [5:0] plane_RGB01;
  planes_cache u_planes_cache (
      .clk      (clk),
      .in_R     (R),
      .in_G     (G),
      .in_B     (B),
      .in_LOAD0 (LOAD0),
      .in_LOAD1 (LOAD1),
      .in_SHIFT (SHIFT),
      .out_RGB01(plane_RGB01)
  );


  localparam CLK_PERIOD = 40;
  always #(CLK_PERIOD / 2) clk = ~clk;

  initial begin
    $dumpfile("planes_cache_TB.vcd");
    $dumpvars(0, planes_cache_TB);
  end

  initial begin
    clk <= 1'bx;
    clk <= 0;
    LOAD0 = 0;
    LOAD1 = 0;
    SHIFT = 0;
    repeat (5) @(posedge clk);
    LOAD0 = 1;
    @(posedge clk);
    LOAD0 = 0;
    repeat (7) @(posedge clk);
    R = 64'hDCBA3210;
    G = 64'hDCBA3210;
    B = 64'hDCBA3210;
    repeat (2) @(posedge clk);
    LOAD1 = 1;
    @(posedge clk);
    LOAD1 = 0;
    for (i = 0; i < 10; i = i + 1) begin
      repeat (6) @(negedge clk);
      SHIFT = 1;
      @(negedge clk);
      SHIFT = 0;
    end
    $finish(2);
  end

endmodule
`default_nettype wire
