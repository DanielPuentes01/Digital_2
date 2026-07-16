module MEM #(
    parameter HEX_FILE = "./test_benches/test_mem_image.hex"
) (
    input clk,
    input wr,
    input [11:0] wr_addr,
    input [7:0] in_data,
    input rd,
    input [9:0] rd_addr,
    output reg [31:0] out_data
);


  (* ram_style = "block" *)
  reg [7:0] mem[0:4095];  //4096 cells 8bits wide

  initial begin
    $readmemh(HEX_FILE, mem);
  end
//https://yosyshq.readthedocs.io/projects/yosys/en/0.40/using_yosys/synthesis/memory.html#synchronous-sdp-read-first
  always @(negedge clk) begin
    if (wr) mem[wr_addr] <= in_data;
    if (rd) begin
      out_data[7:0]   <= mem[{rd_addr, 2'b00}];
      out_data[15:8]  <= mem[{rd_addr, 2'b01}];
      out_data[23:16] <= mem[{rd_addr, 2'b10}];
      out_data[31:24] <= mem[{rd_addr, 2'b11}];
    end
  end
endmodule
