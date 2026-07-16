module acumulador_restando #(
    parameter REG_WIDTH = 2,
    parameter LESS_VALUE = 1
) (
    input clk,
    input rst,
    input [REG_WIDTH-1:0] initial_value,
    input less,
    output reg [REG_WIDTH-1:0] out_K
);

always @(negedge clk) begin
    if (rst)
        out_K = initial_value;
    else if (less)
        out_K = out_K - LESS_VALUE;
end

endmodule