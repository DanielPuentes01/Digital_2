module peripheral_led_matrix (
    clk,
    rst,
    d_in,
    cs,
    addr,
    rd,
    wr,
    d_out
);

  input clk;
  input rst;
  input [15:0] d_in;
  input cs;
  input [4:0] addr;
  input rd;
  input wr;

  output reg [15:0] d_out;

  reg [1:0] select_reg;
  reg init;

  wire DIN;

  always @(*) begin

    if (cs) begin
      case (addr)
        5'h04:   select_reg = 2'b01; // init
        5'h08:   select_reg = 2'b10; // DIN
        default: select_reg = 2'b00;
      endcase
    end else select_reg = 2'b00;

  end

  always @(posedge clk) begin
    if (rst) begin
      init = 0;
    end
    else begin
      if (cs && wr) begin
        init = select_reg[0] ? d_in[0] : init;
      end
    end 
  end

  always @(posedge clk) begin
    if (rst) d_out = 0;
    else if (cs && rd) begin
      case (select_reg)
        2'b01:
          d_out = {15'b0, init};
        2'b10:
          d_out = {15'b0, DIN};

        default:
          d_out = 16'b0;

      endcase

    end

  end

  led_matrix led_matrix (
      .clk (clk),
      .init(init),
      .rst (!rst),
      .DIN (DIN)
  );

endmodule