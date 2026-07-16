module LSR #(
  parameter WIDTH = 8
) (input clk, input [WIDTH-1:0] in_B, input sft, input load, output reg [WIDTH-1:0] s_B);


always @(negedge clk)
  if (load) s_B = in_B ;
  else
   begin
    if(sft) s_B = {s_B[WIDTH-2:0], 1'b0};
    else s_B = s_B;
   end

endmodule

