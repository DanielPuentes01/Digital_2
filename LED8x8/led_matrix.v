module led_matrix (
    clk,
    init,
    rst,
    DIN
);

    input clk;
    input init;
    input rst;

    reg [23:0] mem1 [0:63];
    reg [23:0] mem2 [0:63];
    reg [23:0] mem3 [0:63];
    reg [23:0] mem4 [0:63];
    reg [23:0] mem5 [0:63];
    reg [23:0] mem6 [0:63];

    output wire DIN;

    initial begin
        $readmemh("led_matrix1.mem", mem1);
        $readmemh("led_matrix2.mem", mem2);
        $readmemh("led_matrix3.mem", mem3);
        $readmemh("led_matrix4.mem", mem4);
        $readmemh("led_matrix5.mem", mem5);
        $readmemh("led_matrix6.mem", mem6);
    end

    wire [23:0] mem_out;
    reg [2:0] change_mem;
    reg [24:0] mem_cont;

    always @(posedge clk) begin
        if (!rst) begin
            change_mem <= 0;
            mem_cont <= 0;
        end else if (init) begin
            change_mem <= 0;
            mem_cont <= 0;
        end else if (mem_cont == 25'b0010111110101111000010000) begin
            change_mem <= change_mem + 1;
            mem_cont <= 0;
        end else begin
            mem_cont <= mem_cont + 1;
        end
    end

    multiplexor6x1 #(
      .IN_WIDTH(24)
    ) mux (
      .IN000(mem1[cont]),
      .IN001(mem2[cont]),
      .IN010(mem3[cont]),
      .IN011(mem4[cont]),
      .IN100(mem5[cont]),
      .IN101(mem6[cont]),
      .SELECT(change_mem),
      .MUX_OUT(mem_out)
    );

    wire led_s;
    wire led_done;
    wire RST_TIMER_s;
    wire RST_TIMER_done;
    wire add;
    wire rst_cont;
    wire load_color;
    wire [6:0] cont;
    wire z;

    control_led_matrix control_led_matrix (
        .clk(clk),
        .rst(!rst),
        .init(1),
        .RST_TIMER_s(RST_TIMER_s),
        .RST_TIMER_done(RST_TIMER_done),
        .z(z),
        .led_s(led_s),
        .led_done(led_done),
        .add(add),
        .rst_cont(rst_cont),
        .load_color(load_color)
    );

    led led (
        .clk(clk),
        .rst(load_color),
        .init(led_s),
        .Color_in(mem_out),
        .DIN(DIN),
        .done(led_done)
    );

    acumulador #(
        .WIDTH(7)
    ) cont_acc (
        .clk(clk),
        .rst(rst_cont),
        .plus(add),
        .value(cont)
    );

    comp #(
        .WIDTH(7)
    ) comparador (
        .a(cont),
        .b(7'b1000000),
        .eq(z)
    );

    txx #(
        .WIDTH(14),
        .TIME_COMP(14'b01001110001000)
    ) RST_timer (
        .clk(clk),
        .rst(rst_cont),
        .init(RST_TIMER_s),
        .done(RST_TIMER_done)
    );

endmodule