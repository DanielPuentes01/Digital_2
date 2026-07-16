module pixel_reader #(
    parameter N_BITS_COLOR = 16
)(
    input clk,

    input [7:0] col,
    input [5:0] row,
    input [4:0] plane,

    input [(3*N_BITS_COLOR)-1:0] pixel1,
    input [(3*N_BITS_COLOR)-1:0] pixel2,

    output [12:0] addr1,
    output [12:0] addr2,
    output [2:0] RGB1,
    output [2:0] RGB2
);

    assign addr1 = ({row, 7'b0}) + (7'd127 - col);
    assign addr2 = addr1 + 13'd4096;


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