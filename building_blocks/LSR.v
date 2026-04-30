module LSR #(
  parameter WIDTH = 8
) (clk, in_B , shift , load, rst , s_B);
  input clk;
  input [WIDTH-1:0]in_B;
  input load;
  input shift;
  input rst;
  output reg [WIDTH-1:0]s_B;

always @(negedge clk)
  if(rst) s_B = 0;
  else if(load) s_B = in_B ;
  else
   begin
    if(shift) s_B = {s_B[WIDTH-2:0], 1'b0};
    else s_B = s_B;
   end

endmodule

