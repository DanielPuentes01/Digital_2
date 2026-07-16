module VRAM #(
    parameter HEX_FILE = "./test_benches/test_mem_image.hex"
) (
    input clk,
    input rst,
    input wr,
    input [11:0] wr_addr,  //4096 direcciones una por pixel
    input [7:0] in_data,
    input rd,
    input [5:0] rd_addr,
    output wire [511:0] out_data,
    output reg out_charged
);
  wire [4:0] w_COUNTER_V;
  wire [31:0] wire_rd_byte;

  reg reg_COUNTER_P;
  reg reg_ACC_RST;

  reg reg_inter_write;
  reg reg_inter_read;
  reg [9:0] reg_inter_read_addr;

  parameter IDLE = 0;
  parameter READING = 1;
  parameter SHIFTING = 2;
  reg [1:0] state;

  always @(posedge clk) begin
    if (rst) begin
      reg_inter_read = 0;
      reg_inter_write = 0;
      reg_inter_read_addr = 12'b0;
      reg_ACC_RST = 1;
      reg_COUNTER_P = 0;
      out_charged = 0;
      state = IDLE;
    end else begin
      reg_inter_write = wr;
      case (state)
        IDLE: begin
          if (rd) begin
            reg_inter_read = 1;
            reg_inter_read_addr = {rd_addr, w_COUNTER_V[3:0]};
            reg_ACC_RST = 0;
            reg_COUNTER_P = 0;
            out_charged = 0;
            state = READING;
          end else begin
            reg_inter_read = 0;
            reg_inter_read_addr = 12'b0;
            reg_ACC_RST = 0;
            reg_COUNTER_P = 0;
            out_charged = out_charged;
            state = IDLE;
          end
        end
        READING: begin
          if (w_COUNTER_V[4]) begin
            reg_inter_read = 0;
            reg_inter_read_addr = 12'b0;
            reg_ACC_RST = 1;
            reg_COUNTER_P = 0;
            out_charged = 1;
            state = IDLE;
          end else begin
            reg_inter_read = 0;
            reg_inter_read_addr = 12'b0;
            reg_ACC_RST = 0;
            reg_COUNTER_P = 1;
            out_charged = 0;
            state = SHIFTING;
          end
        end
        SHIFTING: begin
          reg_inter_read = 1;
          reg_inter_read_addr = {rd_addr, w_COUNTER_V[3:0]};
          reg_ACC_RST = 0;
          reg_COUNTER_P = 0;
          out_charged = 0;
          state = READING;
        end
        default: begin
          reg_inter_read = 0;
          reg_inter_read_addr = 12'b0;
          reg_ACC_RST = 1;
          reg_COUNTER_P = 0;
          out_charged = 0;
          state = IDLE;
        end
      endcase
    end
  end

  acumulador #(
      .WIDTH(5),
      .POS_EDGE(0)
  ) u_acumulador (
      .clk  (clk),
      .rst  (reg_ACC_RST),
      .plus (reg_COUNTER_P),
      .value(w_COUNTER_V)
  );

  MultipleRSR #(
      .RST_VALUE({1'b1, 510'b0, 1'b1}),
      .IN_WIDTH(32),
      .SIZE(512)
  ) u_output_reg (
      .clk     (clk),
      .rst     (rst),
      .in_data (wire_rd_byte),
      .in_LOAD (reg_COUNTER_P),
      .out_data(out_data)
  );

  MEM #(
      .HEX_FILE(HEX_FILE)
  ) u_MEM (
      .clk     (clk),
      .wr      (reg_inter_write),
      .wr_addr (wr_addr),
      .in_data (in_data),
      .rd      (reg_inter_read),
      .rd_addr (reg_inter_read_addr),
      .out_data(wire_rd_byte)
  );



`ifdef BENCH
  reg [8*40:1] state_name;
  always @(*) begin
    case (state)
      IDLE: state_name = "IDLE";
      READING: state_name = "READING";
      SHIFTING: state_name = "SHIFTING";
      default: state_name = "NA";
    endcase
  end
`endif

endmodule
