`timescale 1ns / 1ps
module COMMAND_DECODER_TB;
  reg clk;
  reg rst;

  reg other_write;
  reg [7:0] other_px_data;
  reg [5:0] other_column;
  reg [5:0] other_row;
  reg other_image_palette;
  reg other_image_overlay;
  reg other_VRAM_available;

  wire write_available;
  wire write;
  wire [11:0] addr;
  wire [7:0] px_data;
  wire image_or_overlay;
  wire image_select;
  wire RST;


  COMMAND_DECODER u_COMMAND_DECODER (
      .clk                 (clk),
      .rst                 (rst),
      .in_write            (other_write),
      .in_px_data          (other_px_data),
      .in_column           (other_column),
      .in_row              (other_row),
      .in_image_palette    (other_image_palette),
      .in_image_overlay    (other_image_overlay),
      .in_VRAM_available   (other_VRAM_available),
      .out_write_available (write_available),
      .out_write           (write),
      .out_addr            (addr),
      .out_px_data         (px_data),
      .out_image_or_overlay(image_or_overlay),
      .out_image_select    (image_select),
      .out_rst             (RST)
  );


  localparam CLK_PERIOD = 40;
  always #(CLK_PERIOD / 2) clk = ~clk;

  initial begin
    $dumpfile("COMMAND_DECODER_TB.vcd");
    $dumpvars(0, COMMAND_DECODER_TB);
  end

  initial begin
    #1 rst <= 1'bx;
    clk <= 1'bx;
    #(CLK_PERIOD * 3) rst <= 0;
    #(CLK_PERIOD * 3) rst <= 1;
    clk <= 0;
    other_px_data <= 8'hF2;
    other_column <= 6'd13;
    other_row <= 6'd32;
    other_image_palette = 0;
    other_image_overlay = 0;
    other_VRAM_available = 1;
    other_write = 0;
    repeat (5) @(posedge clk);
    rst <= 0;
    @(posedge clk);
    repeat (2) @(negedge clk);
    other_write = 1;
    @(negedge clk);
    other_write = 0;
    repeat (2) @(negedge clk);
    other_image_palette = 1;
    other_write = 1;
    repeat (2) @(negedge clk);
    other_VRAM_available = 0;
    other_image_palette = 0;
    other_write = 1;
    repeat (2) @(negedge clk);
    other_VRAM_available = 1;
    repeat (2) @(negedge clk);
    other_image_overlay = 1;
    other_image_palette = 1;
    repeat (5) @(negedge clk);
    $finish(2);
  end

endmodule
