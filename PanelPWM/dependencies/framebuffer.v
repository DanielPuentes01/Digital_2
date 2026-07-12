module framebuffer #(
    parameter WIDTH = 128,
    parameter HEIGHT = 64,
    parameter PIXEL_BITS = 9
)(
    input clk,

    // Escritura
    input we,
    input [12:0] wr_addr,
    input [PIXEL_BITS-1:0] wr_data,

    // Lectura
    input [12:0] rd_addr1,
    input [12:0] rd_addr2,

    output reg [PIXEL_BITS-1:0] pixel1,
    output reg [PIXEL_BITS-1:0] pixel2
);

    reg [PIXEL_BITS-1:0] mem [0:WIDTH*HEIGHT-1];

    initial begin
        $readmemh("framebuffer.mem", mem);
    end

    always @(negedge clk) begin

        if (we)
            mem[wr_addr] <= wr_data;

        pixel1 <= mem[rd_addr1];
        pixel2 <= mem[rd_addr2];

    end

endmodule