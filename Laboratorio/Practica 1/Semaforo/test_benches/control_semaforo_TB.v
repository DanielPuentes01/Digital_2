`timescale 1ns/1ps

module control_semaforo_TB;
    reg clk;
    reg rst;

    wire GRN;
    wire YLW;
    wire RED;

    control_semaforo uut (
        .clk(clk),
        .rst(rst),
        .out_grn(GRN),
        .out_ylw(YLW),
        .out_red(RED)
    );

    localparam CLK_PERIOD = 40;
    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        $dumpfile("control_semaforo_TB.vcd");
        $dumpvars(0, control_semaforo_TB);
    end

    initial begin
        clk <= 1'bx;
        #(CLK_PERIOD * 3) rst <= 1;
        #(CLK_PERIOD * 3) rst <= 0;
        clk <= 0;
        repeat (5) @(posedge clk);
        rst <= 1;
        @(posedge clk);
        rst <=0;
        repeat (40) @(posedge clk);
        $finish(2);

    end

endmodule
`default_nettype wire