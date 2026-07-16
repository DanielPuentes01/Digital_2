`timescale 1ns / 1ps
module VRAM_TB;
  reg clk;
  reg rst_n;
  reg [5:0] rd_addr = 6'b0;
  wire [511:0] read_data;
  reg rd =0;
  reg [11:0] wr_addr = 12'b0;
  reg wr=0;
  reg [7:0] in_data = 8'b11111111;
  wire charged;
  VRAM u_VRAM (
      .clk     (clk),
      .rst(!rst_n),
      .wr      (wr),
      .wr_addr (wr_addr),
      .in_data (in_data),
      .rd      (rd),
      .rd_addr (rd_addr),
      .out_data(read_data),
      .out_charged(charged)
  );


  localparam CLK_PERIOD = 40;
  always #(CLK_PERIOD / 2) clk = ~clk;

  initial begin
    $dumpfile("VRAM_TB.vcd");
    $dumpvars(0, VRAM_TB);
  end
  integer i;
  initial begin
    #1 rst_n <= 1'bx;
    clk <= 1'bx;
    #(CLK_PERIOD * 3) rst_n <= 1;
    #(CLK_PERIOD * 3) rst_n <= 0;
    clk <= 0;
    repeat (5) @(posedge clk);
    rst_n <= 1;
    @(posedge clk);

    @(negedge clk);
    rd = 1;
    wr = 0;
    for (i = 0; i < 5; i = i + 1) begin
      rd = 0;
      repeat (65) @(posedge clk);
      @(negedge clk);
      rd=1;
      rd_addr = rd_addr + 1;
      repeat (2) @(posedge clk);
    end
    @(negedge clk);
    rd = 0;
    repeat (65) @(posedge clk);
    @(negedge clk);
    rd = 0;
    wr = 1;
    rd_addr = 0;
    wr_addr = 65;
    @(negedge clk);
    wr = 0;
    repeat (65) @(posedge clk);
    @(negedge clk);
    rd = 1;
    wr = 0;
    rd_addr = 1;
    wr_addr = 0;
    @(negedge clk);
    rd = 0;
    repeat (65) @(posedge clk);
    @(negedge clk);
    rd = 0;
    wr = 0;
    rd_addr = 0;
    wr_addr = 0;
    @(negedge clk);
    rd = 1;
    wr = 1;
    rd_addr = 1;
    wr_addr = 67;
    in_data = 8'hEE;
    @(negedge clk);
    rd = 0;
    wr = 0;
    repeat (65) @(posedge clk);
    $finish(2);
  end

endmodule
