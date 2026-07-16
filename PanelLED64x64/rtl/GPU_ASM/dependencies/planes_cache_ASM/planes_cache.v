module planes_cache (
    input clk,
    input [63:0] in_R,  //guardo cada canal al tiempo
    input [63:0] in_G,
    input [63:0] in_B,
    input in_LOAD0,
    input in_LOAD1,
    input in_SHIFT,
    output reg [5:0] out_RGB01
);
  reg [63:0] reg_cache_R0;
  reg [63:0] reg_cache_G0;
  reg [63:0] reg_cache_B0;
  reg [63:0] reg_cache_R1;
  reg [63:0] reg_cache_G1;
  reg [63:0] reg_cache_B1;

  always @(*) begin
    out_RGB01[5:3] = {reg_cache_R0[0], reg_cache_G0[0], reg_cache_B0[0]};
    out_RGB01[2:0] = {reg_cache_R1[0], reg_cache_G1[0], reg_cache_B1[0]};
  end
  always @(posedge clk) begin
    if (in_LOAD0) begin
      reg_cache_R0 = in_R;
      reg_cache_G0 = in_G;
      reg_cache_B0 = in_B;
    end else if (in_LOAD1) begin
      reg_cache_R1 = in_R;
      reg_cache_G1 = in_G;
      reg_cache_B1 = in_B;
    end else if (in_SHIFT) begin
      reg_cache_R0 = reg_cache_R0 >> 1;
      reg_cache_G0 = reg_cache_G0 >> 1;
      reg_cache_B0 = reg_cache_B0 >> 1;
      reg_cache_R1 = reg_cache_R1 >> 1;
      reg_cache_G1 = reg_cache_G1 >> 1;
      reg_cache_B1 = reg_cache_B1 >> 1;
    end else begin
      reg_cache_R0 = reg_cache_R0;
      reg_cache_G0 = reg_cache_G0;
      reg_cache_B0 = reg_cache_B0;
      reg_cache_R1 = reg_cache_R1;
      reg_cache_G1 = reg_cache_G1;
      reg_cache_B1 = reg_cache_B1;
    end
  end
endmodule
