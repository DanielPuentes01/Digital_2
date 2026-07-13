module four_clk #(
    parameter N_BITS = 3,
    parameter N_CLKS = 4
)(
    input clk,
    input rst,
    input init,

    output wire w_clk,
    output wire done
);

wire rst_cont;
wire add_cont;
wire cont_done;

wire [N_BITS-1:0] cont;


control_four_clk control(
    .clk(clk),
    .rst(rst),
    .init(init),
    .cont_done(cont_done),
    .w_clk(w_clk),
    .add_cont(add_cont),
    .rst_cont(rst_cont),
    .done(done)
);

acumulador #(
    .WIDTH(N_BITS),
    .RST_VALUE(0)
)
contador(
    .clk(clk),
    .rst(rst_cont),
    .plus(add_cont),
    .value(cont)
);

comp #(
    .WIDTH(N_BITS)
)
comparador(
    .a(cont),
    .b(N_CLKS),
    .eq(cont_done)
);

endmodule