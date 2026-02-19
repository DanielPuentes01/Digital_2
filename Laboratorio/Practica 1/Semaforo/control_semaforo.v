module control_semaforo (
  clk,
  rst, 
  out_grn,
  out_ylw,
  out_red
);
  
  input clk;
  input rst;
  output reg out_grn;
  output reg out_ylw;
  output reg out_red;

  parameter GREEN = 2'b01;
  parameter YELLOW = 2'b10;
  parameter RED = 2'b11;

  reg [1:0] state;
  reg [2:0] timer;

  
  always @(posedge clk) begin
    if(rst) begin
      state = GREEN;
      timer = 3'b0;
    end else begin
       case (state)
          GREEN: begin
            timer = timer + 1;
            if (timer == 3'b101) begin
              state = YELLOW;
              timer = 3'b0;
            end else begin
              state = GREEN;
            end
          end
          YELLOW: begin
            timer = timer + 1;
            if (timer == 3'b010) begin
              timer = 3'b0;
              state = RED;
            end else begin
              state = YELLOW;
            end
          end
          RED: begin
            timer = timer + 1;
            if (timer == 3'b100) begin
              timer = 3'b0;
              state = GREEN;
            end else begin
              state = RED;
            end
          end
          default: begin
            state = GREEN;
          end
       endcase
    end  
  end

  always @(*) begin
      case (state) 
        GREEN: begin
          out_grn = 1;
          out_ylw = 0;
          out_red = 0;
        end
        YELLOW: begin
          out_grn = 0;
          out_ylw = 1;
          out_red = 0;
        end
        RED: begin
          out_grn = 0;
          out_ylw = 0;
          out_red = 1;
        end
        default: begin
          out_grn = 1;
          out_ylw = 0;
          out_red = 0;
        end
      endcase
    
  end



    
endmodule


