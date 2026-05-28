`timescale 1ns / 1ps
`define SIMULATION

module peripheral_led_matrix_TB;

  reg clk;
  reg rst;
  reg [15:0] d_in;
  reg cs;
  reg [4:0] addr;
  reg rd;
  reg wr;
  wire [15:0] d_out;

  peripheral_led_matrix uut (
      .clk  (clk),
      .rst  (!rst),
      .d_in (d_in),
      .cs   (cs),
      .addr (addr),
      .rd   (rd),
      .wr   (wr),
      .d_out(d_out)
  );

  parameter PERIOD = 20;
  initial begin
    clk  = 0;
    rst  = 0;
    d_in = 0;
    addr = 0;
    cs   = 0;
    rd   = 0;
    wr   = 0;
  end

  initial clk = 0;
  always #(PERIOD/2) clk = ~clk;


  initial begin

    forever begin

      @(negedge clk);
      rst = 1;

      @(negedge clk);
      rst = 0;

      #(PERIOD * 4);

      cs   = 1;
      rd   = 0;
      wr   = 1;

      d_in = 16'h0001;
      addr = 5'h04;

      #(PERIOD * 2 );

      cs = 0;
      rd = 0;
      wr = 0;

      #(PERIOD * 10);


      cs   = 1;
      rd   = 1;
      wr   = 0;

      addr = 5'h08;

      #(PERIOD);

      cs = 0;
      rd = 0;
      wr = 0;

      #(PERIOD * 20);


      cs   = 1;
      rd   = 0;
      wr   = 1;

      d_in = 16'h0000;
      addr = 5'h04;

      #(PERIOD);

      cs = 0;
      rd = 0;
      wr = 0;

      #(PERIOD * 100000);

    end

  end


  initial begin : TEST_CASE

    $dumpfile("peripheral_led_matrix_TB.vcd");
    $dumpvars(-1, peripheral_led_matrix_TB);

    #(PERIOD * 1000000) $finish;

  end

endmodule