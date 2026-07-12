`timescale 1ns / 1ps

module latch_command_TB;

reg clk;
reg rst;
reg init;

wire latch;
wire w_clk;
wire done;

latch_command #(
    .n_bits_comando(4),
    .n_ciclos_comando(7)
) uut (
    .clk(clk),
    .rst(rst),
    .init(init),
    .latch(latch),
    .w_clk(w_clk),
    .done(done)
);

parameter PERIOD = 20;
parameter real DUTY_CYCLE = 0.5;
parameter OFFSET = 0;

event reset_trigger;
event reset_done_trigger;

//----------------------
// Reset
//----------------------
initial begin
    forever begin
        @(reset_trigger);
        @(negedge clk);
        rst = 1;
        repeat(2) @(negedge clk);
        rst = 0;
        -> reset_done_trigger;
    end
end

//----------------------
// Clock
//----------------------
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

//----------------------
// Initial values
//----------------------
initial begin
    rst  = 0;
    init = 0;
end

//----------------------
// Stimulus
//----------------------
initial begin
    #10 -> reset_trigger;
    @(reset_done_trigger);

    @(posedge clk);
    init = 1;

    @(posedge clk);
    init = 0;

    @(posedge done);

    #(PERIOD * 10);
    $finish;
end

//----------------------
// Waveform
//----------------------
initial begin
    $dumpfile("latch_command_TB.vcd");
    $dumpvars(-1, uut);

    #(PERIOD * 50000);
    $finish;
end

endmodule