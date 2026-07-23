module LSR_ADD #(
  parameter WIDTH = 8
) (clk, in_B , sft , rst , s_B);
  input clk;
  input in_B;
  input rst;
  input sft;
  output reg [WIDTH-1:0]s_B;

always @(negedge clk)
  if (rst) s_B = 0 ;
  else
   begin
    if(sft) s_B = {s_B[WIDTH-2:0], in_B};
    else s_B = s_B;
   end

endmodule

