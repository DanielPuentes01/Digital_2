`timescale 1ns / 1ps
module led_matrix_TB;
reg clk;
reg rst;
reg init;
wire DIN;

led_matrix uut(       
  .clk(clk),
  .rst(!rst),
  .init(init),
  .DIN(DIN)
);

parameter PERIOD         = 40;
parameter real DUTY_CYCLE = 0.5;
parameter OFFSET         = 0;

event reset_trigger;
event reset_done_trigger;

initial begin
  forever begin
    @(reset_trigger);
    @(negedge clk);
    rst = 1;
    repeat(2) @(negedge clk);
    rst = 0;
    ->reset_done_trigger;
  end
end

initial begin
  clk = 0;
  #OFFSET;
  forever begin
    clk = 1'b0;
    #(PERIOD - (PERIOD * DUTY_CYCLE));
    clk = 1'b1;
    #(PERIOD * DUTY_CYCLE);
  end
end

initial begin
  rst  = 0;             
  init = 0;
end

initial begin
  #10 ->reset_trigger;
  @(reset_done_trigger);
  @(posedge clk);
  init = 1;
  @(posedge clk);
  init = 0;
end

initial begin
  $dumpfile("led_matrix_TB.vcd");  
  $dumpvars(0, uut);
  #(PERIOD * 5000000) $finish;
end

endmodule