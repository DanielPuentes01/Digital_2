`timescale 1ns/1ps

module panel_pwm_TB;

    reg clk;
    reg n_rst;
    reg init;
    reg we;
    reg [12:0] wr_addr;
    reg [47:0] wr_data;

    wire [2:0] RGB1;
    wire [2:0] RGB2;
    wire OE;
    wire w_clk;
    wire latch;
    wire [4:0] ABCDE;
    wire done;

    panel_pwm DUT (
        .init(init),
        .clk(clk),
        .n_rst(!n_rst),
        .we(we),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .RGB1(RGB1),
        .RGB2(RGB2),
        .OE(OE),
        .w_clk(w_clk),
        .latch(latch),
        .ABCDE(ABCDE),
        .done(done)
    );

    // Reloj de 27 MHz (aprox.)
    initial begin
        clk = 0;
        forever #18.5 clk = ~clk;
    end

    initial begin
        $dumpfile("panel_pwm_TB.vcd");
        $dumpvars(0, panel_pwm_TB);

        n_rst  = 1;
        init = 0;
        we = 0;
        wr_addr = 0;
        wr_data = 0;

        #100;

        n_rst = 0;

        #100;

        init = 1;

        // Solo un pulso
        #37;
        init = 0;

        @(posedge done);
        @(posedge done);

        #1000;

        $finish;
    end

endmodule