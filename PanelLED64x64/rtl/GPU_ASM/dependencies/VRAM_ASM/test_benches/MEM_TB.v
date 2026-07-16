`timescale 1ns / 1ps
module MEM_TB;
  reg clk;
  reg [9:0] rd_addr = 6'b0;
  wire [31:0] read_data;
  reg rd;
  reg [11:0] wr_addr = 12'd2;
  reg wr;
  reg [7:0] in_data = 8'hFF;
  MEM u_MEM (
      .clk     (clk),
      .wr      (wr),
      .wr_addr (wr_addr),
      .in_data (in_data),
      .rd      (rd),
      .rd_addr (rd_addr),
      .out_data(read_data)
  );


  localparam CLK_PERIOD = 40;
  always #(CLK_PERIOD / 2) clk = ~clk;

  initial begin
    $dumpfile("MEM_TB.vcd");
    $dumpvars(0, MEM_TB);
  end
  integer i;
  initial begin
    clk <= 1'bx;
    #(CLK_PERIOD * 3);
    #(CLK_PERIOD * 3) clk <= 0;
    @(posedge clk);
    rd = 1;
    wr = 0;
    for (i = 0; i < 5; i = i + 1) begin
      repeat (5) @(posedge clk);
      @(negedge clk);
      rd_addr = rd_addr + 1;
      repeat (2) @(posedge clk);
    end
    @(posedge clk);
    rd = 0;
    wr = 1;
    rd_addr = 0;
    wr_addr = 63;
    repeat (5) @(posedge clk);
    @(posedge clk);
    rd = 1;
    wr = 0;
    rd_addr = 0;
    wr_addr = 0;
    repeat (5) @(posedge clk);
    @(posedge clk);
    in_data = 8'hEE;
    rd = 1;
    wr = 1;
    rd_addr = 0;
    wr_addr = 2;
    @(posedge clk);
    in_data = 8'hEE;
    rd = 1;
    wr = 0;
    rd_addr = 1;
    wr_addr = 2;
    repeat (5) @(posedge clk);
    $finish(2);
  end

endmodule