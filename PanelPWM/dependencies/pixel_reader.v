module pixel_reader #(
    parameter N_BITS_COLOR = 3
)(
    input clk,

    input [7:0] col,
    input [5:0] row,
    input [N_BITS_COLOR-1:0] plane,

    input we,
    input [12:0] wr_addr,
    input [8:0] wr_data,

    output [2:0] RGB1,
    output [2:0] RGB2
);

    wire [5:0] row2;
    wire [12:0] addr1;
    wire [12:0] addr2;
    wire [8:0] pixel1;
    wire [8:0] pixel2;
    assign row2 = row + 6'd32;
    assign addr1 = {row, col};
    assign addr2 = {row2, col};

    framebuffer #(
        .WIDTH(128),
        .HEIGHT(64),
        .PIXEL_BITS(3*N_BITS_COLOR)
    )
    fb(
        .clk(clk),

        .we(we),
        .wr_addr(wr_addr),
        .wr_data(wr_data),

        .rd_addr1(addr1),
        .rd_addr2(addr2),

        .pixel1(pixel1),
        .pixel2(pixel2)
    );

    assign RGB1 = {
        pixel1[(plane-1) + (2*N_BITS_COLOR)],
        pixel1[(plane-1) + N_BITS_COLOR],
        pixel1[(plane-1)]
    };

    assign RGB2 = {
        pixel2[(plane-1) + (2*N_BITS_COLOR)],
        pixel2[(plane-1) + N_BITS_COLOR],
        pixel2[(plane-1)]
    };

endmodule