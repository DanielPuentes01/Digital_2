module control_I2C(
  input init,
  input clk,
  input rst,
  input SDA_IN,
  input cont_clk_done,
  input scl_m_done,
  input wr,
  input k,
  input z,
  input stop,
  output reg SDA_OUT,
  output reg SCL_M,
  output reg add,
  output reg rst_cont,
  output reg out_SCL,
  output reg cont_clk_s,
  output reg out_rst,
  output reg rst_scl_m,
  output reg sft_data_rd,
  output reg sft_data_wr,
  output reg sft_addr,
  output reg done
);

reg [4:0] state;

parameter INIT = 5'b00000;
parameter START1 = 5'b00001;
parameter START2 = 5'b00010;
parameter CONT1 = 5'b00011;
parameter SCL_M1 = 5'b00100;
parameter RDWR = 5'b00101;
parameter SCL_M2 = 5'b00110;
parameter ACK1 = 5'b00111;
parameter SCL_M3 = 5'b01000;
parameter SFT_DATA_WR = 5'b01001;
parameter SCL_M4 = 5'b01010;
parameter ACKWR = 5'b01011;
parameter SCL_M5 = 5'b01100;
parameter LOAD_NEW_DATA = 5'b01101;
parameter SFT_DATA_RD = 5'b01110;
parameter SCL_M6 = 5'b01111;
parameter ACKRD = 5'b10000;
parameter SCL_M7 = 5'b10001;
parameter END_CLK = 5'b10010;
parameter END_COND1 = 5'b10011;
parameter END_COND2 = 5'b10100;

always @(posedge clk) begin
  if (rst) begin
    state = INIT;
  end else begin
    case (state)
      INIT : begin
        state = (init) ? START1 : INIT;
      end 
      START1 : begin
        state = cont_clk_done ? START2 : START1;
      end
      START2 : begin
        state = CONT1;
      end
      CONT1 : begin
        state = SCL_M1;
      end
      SCL_M1 : begin
        if (!scl_m_done) begin
          state = SCL_M1;
        end else begin
          state = k ? RDWR : CONT1;
        end
      end
      RDWR : begin
        state = SCL_M2;
      end
      SCL_M2 : begin
        state = scl_m_done ? ACK1 : SCL_M2;
      end    
      ACK1 : begin
        state = SCL_M3;
      end
      SCL_M3 : begin
        if (!scl_m_done) begin
          state = SCL_M3;
        end else begin
          if (!SDA_IN) begin
            state = CONT1;
          end else begin
            state = wr ? SFT_DATA_WR : SFT_DATA_RD;
          end
        end
      end
      SFT_DATA_WR : begin
        state = SCL_M4;
      end
      SCL_M4 : begin
        if (!scl_m_done) begin
          state = SCL_M4;
        end else begin
          state = z ? ACKWR : SFT_DATA_WR;
        end
      end
      ACKWR : begin
        state = SCL_M5;
      end
      SCL_M5 : begin
        if (!scl_m_done) begin
          state = SCL_M5;
        end else begin
          if (!SDA_IN) begin
            state = SFT_DATA_WR;
          end else begin
            state = stop ? END_CLK : LOAD_NEW_DATA;
          end
        end
      end
      LOAD_NEW_DATA : begin
        state = SFT_DATA_WR;
      end
      SFT_DATA_RD : begin
        state = SCL_M6;
      end
      SCL_M6 : begin
        if (!scl_m_done) begin
          state = SCL_M6;
        end else begin
          state = z ? ACKRD : SFT_DATA_RD;
        end
      end
      ACKRD : begin
        state = SCL_M7;
      end
      SCL_M7 : begin
        if (!scl_m_done) begin
          state = SCL_M7;
        end else begin
          state = stop ? END_CLK : SFT_DATA_RD;
        end
      end
      END_CLK : begin
        state = cont_clk_done ? END_COND1 : END_CLK;
      end
      END_COND1 : begin
        state = END_COND2;
      end
      END_COND2 : begin
        state = INIT;
      end
      default : state = INIT;
    endcase
  end    
end

always @(*) begin
  case(state)
    INIT: begin
      SDA_OUT     = 1;
      SCL_M       = 0;
      add         = 0;
      rst_cont    = 1;
      out_SCL     = 1;
      cont_clk_s  = 0;
      out_rst     = 1;
      rst_scl_m   = 1;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    START1: begin
      SDA_OUT     = 0;
      SCL_M       = 0;
      add         = 0;
      rst_cont    = 0;
      out_SCL     = 1;
      cont_clk_s  = 1;
      out_rst     = 0;
      rst_scl_m   = 0;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    START2: begin
      SDA_OUT     = 0;
      SCL_M       = 0;
      add         = 0;
      rst_cont    = 0;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 1;
      rst_scl_m   = 0;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    CONT1: begin
      SDA_OUT     = 0;
      SCL_M       = 0;
      add         = 1;
      rst_cont    = 0;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 0;
      rst_scl_m   = 0;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 1;
      done        = 0;
    end 

    SCL_M1: begin
      SDA_OUT     = 0;
      SCL_M       = 1;
      add         = 0;
      rst_cont    = 0;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 0;
      rst_scl_m   = 0;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    RDWR: begin
      SDA_OUT     = wr ? 1 : 0;
      SCL_M       = 0;
      add         = 0;
      rst_cont    = 1;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 0;
      rst_scl_m   = 1;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    SCL_M2: begin
      SDA_OUT     = wr ? 1 : 0;
      SCL_M       = 1;
      add         = 0;
      rst_cont    = 0;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 0;
      rst_scl_m   = 0;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    ACK1: begin
      SDA_OUT     = 1;
      SCL_M       = 0;
      add         = 0;
      rst_cont    = 0;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 0;
      rst_scl_m   = 1;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    SCL_M3: begin
      SDA_OUT     = 1;
      SCL_M       = 1;
      add         = 0;
      rst_cont    = 0;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 0;
      rst_scl_m   = 0;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    SFT_DATA_WR: begin
      SDA_OUT     = 0;
      SCL_M       = 0;
      add         = 1;
      rst_cont    = 0;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 0;
      rst_scl_m   = 1;
      sft_data_rd = 0;
      sft_data_wr = 1;
      sft_addr    = 0;
      done        = 0;   
    end

    SCL_M4: begin
      SDA_OUT     = 0;
      SCL_M       = 1;
      add         = 0;
      rst_cont    = 0;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 0;
      rst_scl_m   = 0;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    ACKWR: begin
      SDA_OUT     = 1;
      SCL_M       = 0;
      add         = 0;
      rst_cont    = 1;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 0;
      rst_scl_m   = 1;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    SCL_M5: begin
      SDA_OUT     = 1;
      SCL_M       = 1;
      add         = 0;
      rst_cont    = 0;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 0;
      rst_scl_m   = 0;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    LOAD_NEW_DATA: begin
      SDA_OUT     = 0;
      SCL_M       = 0;
      add         = 0;
      rst_cont    = 0;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 1;
      rst_scl_m   = 0;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    SFT_DATA_RD: begin
      SDA_OUT     = 1;
      SCL_M       = 0;
      add         = 1;
      rst_cont    = 0;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 0;
      rst_scl_m   = 0;
      sft_data_rd = 1;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    SCL_M6: begin
      SDA_OUT     = 1;
      SCL_M       = 1;
      add         = 0;
      rst_cont    = 0;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 0;
      rst_scl_m   = 0;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    ACKRD: begin
      SDA_OUT     = 0;
      SCL_M       = 0;
      add         = 0;
      rst_cont    = 1;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 0;
      rst_scl_m   = 1;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    SCL_M7: begin
      SDA_OUT     = 0;
      SCL_M       = 1;
      add         = 0;
      rst_cont    = 0;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 0;
      rst_scl_m   = 0;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    END_CLK: begin
      SDA_OUT     = 0;
      SCL_M       = 0;
      add         = 0;
      rst_cont    = 0;
      out_SCL     = 0;
      cont_clk_s  = 1;
      out_rst     = 0;
      rst_scl_m   = 0;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    END_COND1: begin
      SDA_OUT     = 0;
      SCL_M       = 0;
      add         = 0;
      rst_cont    = 0;
      out_SCL     = 1;
      cont_clk_s  = 0;
      out_rst     = 0;
      rst_scl_m   = 0;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

    END_COND2: begin
      SDA_OUT     = 1;
      SCL_M       = 0;
      add         = 0;
      rst_cont    = 0;
      out_SCL     = 0;
      cont_clk_s  = 0;
      out_rst     = 1;
      rst_scl_m   = 0;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 1;
    end

    default: begin
      SDA_OUT     = 1;
      SCL_M       = 0;
      add         = 0;
      rst_cont    = 1;
      out_SCL     = 1;
      cont_clk_s  = 0;
      out_rst     = 1;
      rst_scl_m   = 1;
      sft_data_rd = 0;
      sft_data_wr = 0;
      sft_addr    = 0;
      done        = 0;
    end

  endcase
end
        

endmodule