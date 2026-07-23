module multiplexor6x1 #(
    parameter IN_WIDTH = 1
) (
    input [IN_WIDTH-1:0] IN000,
    input [IN_WIDTH-1:0] IN001,
    input [IN_WIDTH-1:0] IN010,
    input [IN_WIDTH-1:0] IN011,
    input [IN_WIDTH-1:0] IN100,
    input [IN_WIDTH-1:0] IN101,
    input [2:0] SELECT,
    output  reg [IN_WIDTH-1:0] MUX_OUT
);
    always @(*) begin
      case (SELECT)
        3'b000: MUX_OUT = IN000;
        3'b001: MUX_OUT = IN001;
        3'b010: MUX_OUT = IN010;
        3'b011: MUX_OUT = IN011;
        3'b100: MUX_OUT = IN100;
        3'b101: MUX_OUT = IN101;
        default: MUX_OUT = IN000;
      endcase
    end
endmodule
