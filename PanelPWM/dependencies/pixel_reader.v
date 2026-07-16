module pixel_reader #(
    parameter N_BITS_COLOR = 16
)(
    input clk,

    input [6:0] col,//no Incluye 128
    input [4:0] row,//no Inluye 32
    input [4:0] plane,

    input we,
    input [12:0] wr_addr,//8192 - 1
    input [(3*N_BITS_COLOR)-1:0] wr_data,

    output [2:0] RGB1,
    output [2:0] RGB2
);

    wire [5:0] row2;
    wire [12:0] addr1;
    wire [12:0] addr2;
    wire [(3*N_BITS_COLOR)-1:0] pixel1;
    wire [(3*N_BITS_COLOR)-1:0] pixel2;

    assign addr1 = {row,col};
    assign addr2 = addr1 | 13'd4096;

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
        pixel1[(3*N_BITS_COLOR - 1) - plane],
        pixel1[(2*N_BITS_COLOR - 1) - plane],
        pixel1[(1*N_BITS_COLOR - 1) - plane]
    };

    assign RGB2 = {
        pixel2[(3*N_BITS_COLOR - 1) - plane],
        pixel2[(2*N_BITS_COLOR - 1) - plane],
        pixel2[(1*N_BITS_COLOR - 1) - plane]
    };

endmodule