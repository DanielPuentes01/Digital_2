`timescale 1ns / 1ps

module send_frame_TB;

reg clk;
reg rst;
reg init;

wire latch;
wire OE;
wire w_clk;
wire [2:0] RGB1;
wire [2:0] RGB2;
wire done;

send_frame #(
    .n_bits_color(1)
) uut (
    .clk(clk),
    .rst(rst),
    .init(init),
    .latch(latch),
    .OE(OE),
    .w_clk(w_clk),
    .RGB1(RGB1),
    .RGB2(RGB2),
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
        clk = 0;
        #(PERIOD-(PERIOD*DUTY_CYCLE));
        clk = 1;
        #(PERIOD*DUTY_CYCLE);
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

    #(PERIOD*20);

    $finish;

end

//----------------------
// Monitor
//----------------------
initial begin
    $monitor(
        "t=%0t init=%b row=%0d col=%0d RGB1=%b RGB2=%b OE=%b LATCH=%b CLK=%b",
        $time,
        init,
        uut.cont_ABCDE,
        uut.cont_col,
        RGB1,
        RGB2,
        OE,
        latch,
        w_clk
    );
end

//----------------------
// Waveform
//----------------------
initial begin

    $dumpfile("send_frame_TB.vcd");
    $dumpvars(-1, uut);

    #(PERIOD*50000);
    $finish;

end

endmodule