`timescale 1ns / 1ps
module I2C_TB;
reg clk;
reg rst;
reg start;
reg [6:0] slave_address;
reg [7:0] data;
reg wr;
reg stop;
wire SDA;
wire SCL;
wire done;

I2C uut(
    .clk(clk),
    .rst(rst),
    .init(start),
    .slave_address(slave_address),
    .data(data),
    .wr(wr),
    .stop(stop),
    .SDA(SDA),
    .SCL(SCL),
    .done(done)
);

parameter PERIOD     = 20;
parameter real DUTY_CYCLE = 0.5;
parameter OFFSET     = 0;

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
    rst          = 0;
    start        = 0;
    slave_address = 7'b0110101;
    data         = 8'b01001100;
    wr           = 1;
    stop         = 0;
end

initial begin
    #10 ->reset_trigger;
    @(reset_done_trigger);

    @(posedge clk);
    start = 1;
    @(posedge clk);
    start = 0;

    #(PERIOD * 10000);
    stop = 1;

    @(posedge done);
    #(PERIOD * 10);
    $finish;
end

initial begin
    $dumpfile("I2C_TB.vcd");
    $dumpvars(-1, uut);
    #(PERIOD * 50000) $finish;
end

endmodule