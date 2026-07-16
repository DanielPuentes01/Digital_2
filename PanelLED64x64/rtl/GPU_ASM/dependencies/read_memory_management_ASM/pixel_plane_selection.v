module pixel_plane_selection (
    input [7:0] px_data,
    input [1:0] selection,
    //RRRGGGBB
    //76543210
    output reg R,
    output reg G,
    output reg B
);
  always @(*) begin
    case (selection)
      2'b00: begin
        R = px_data[5];
        G = px_data[2];
        B = 1'b0;
      end
      2'b01: begin
        R = px_data[6];
        G = px_data[3];
        B = px_data[0];
      end
      2'b10: begin
        R = px_data[7];
        G = px_data[4];
        B = px_data[1];
      end
      default: begin
        R = 1'b0;
        G = 1'b0;
        B = 1'b0;
      end
    endcase
  end
endmodule
