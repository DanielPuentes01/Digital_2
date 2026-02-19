module comp #(
    parameter WIDTH = 4
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    output             eq
);

    assign eq = (a == b);

endmodule