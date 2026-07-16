module GPU #(
    parameter IMAGE_FILE   = "/home/daniel22n4/Documents/2026-1/Digital/Repositorios/Digital_2/PanelLED64x64/rtl/GPU_ASM/test_benches/frame0.hex",
    parameter OVERLAY_FILE = "/home/daniel22n4/Documents/2026-1/Digital/Repositorios/Digital_2/PanelLED64x64/rtl/GPU_ASM/test_benches/overlay.hex",
    parameter PALETTE_FILE = "/home/daniel22n4/Documents/2026-1/Digital/Repositorios/Digital_2/PanelLED64x64/rtl/GPU_ASM/test_benches/frame1.hex"
) (
    input clk,
    input rst_n,
    input write,
    input [7:0] px_data,
    input [5:0] column,
    input [5:0] row,
    input image_palette,
    input image_overlay,

    output [2:0] to_screen_RGB0,
    output [2:0] to_screen_RGB1,
    output to_screen_CLK,
    output [4:0] to_screen_ABCDE,
    output to_screen_LATCH,
    output to_screen_nOE
);
  wire w_HUB75_INIT;
  wire [4:0] w_ROW;
  wire w_HUB75_RST;
  wire w_HUB75_SHOW;
  wire w_HUB75_WAITING;
  wire w_HUB75_ITER;
  wire [2:0] w_HUB75_RGB0;
  wire [2:0] w_HUB75_RGB1;

  wire w_BRIGH_DIM;

  wire [63:0] w_PLANES_CACHE_RED;
  wire [63:0] w_PLANES_CACHE_GREEN;
  wire [63:0] w_PLANES_CACHE_BLUE;
  wire w_PLANES_CACHE_LOAD0;
  wire w_PLANES_CACHE_LOAD1;
  wire w_PLANES_CACHE_SHIFT;
  wire [5:0] w_PLANES_CACHE_RGB01;

  wire w_CONTROL_CACHE;
  wire [1:0] w_CONTROL_PLANE_SELECT;
  wire w_CONTROL_SHIFT_PLANE;
  wire w_CONTROL_PLANE_READY;
  wire w_CONTROL_RST;

  wire w_MEM_MANG_RD;
  wire [5:0] w_MEM_MANG_ADDR;
  wire w_ROW_CACHE_ROW_LOAD0;
  wire w_ROW_CACHE_ROW_LOAD1;

  wire [511:0] w_IMAGE_DATA;
  wire [511:0] w_PALETTE_DATA;
  wire [511:0] w_OVERLAY_DATA;
  wire [511:0] w_FRAME_DATA;
  wire [511:0] w_ROW0_DATA;
  wire [511:0] w_ROW1_DATA;

  wire [511:0] w_MUX_SELECTED_IMAGE;

  wire w_VRAM_IMAGE_SIGNAL;
  wire w_VRAM_OVERLAY_SIGNAL;
  wire w_VRAM_PALETTE_SIGNAL;
  wire w_VRAM_SIGNAL;
  assign w_VRAM_SIGNAL = w_VRAM_OVERLAY_SIGNAL & (w_VRAM_PALETTE_SIGNAL | w_VRAM_IMAGE_SIGNAL);
  wire w_VRAM_AVAILABLE;

  wire w_CMD_WRITE;
  wire [7:0] w_CMD_PX_DATA;
  wire [11:0] w_CMD_WR_ADDR;
  wire w_CMD_IMAGE_OR_OVERLAY;
  wire w_CMD_IMAGE_SELECT;

  wire w_SYNC_WR_IMAGE;
  wire w_SYNC_WR_OVERLAY;
  wire [7:0] w_SYNC_PX_DATA;
  wire [11:0] w_SYNC_WR_ADDR;
  wire w_VRAM_RST;

  wire w_SUPER_RST;
  COMMAND_DECODER u_COMMAND_DECODER (
      .clk                 (clk),
      .rst                 (rst_n),
      .in_write            (write),
      .in_px_data          (px_data),
      .in_column           (column),
      .in_row              (row),
      .in_image_palette    (image_palette),
      .in_image_overlay    (image_overlay),
      .out_write           (w_CMD_WRITE),
      .out_addr            (w_CMD_WR_ADDR),
      .out_px_data         (w_CMD_PX_DATA),
      .out_image_or_overlay(w_CMD_IMAGE_OR_OVERLAY),
      .out_image_select    (w_CMD_IMAGE_SELECT),
      .out_rst             (w_SUPER_RST)
  );

  write_memory_management u_write_memory_management (
      .clk                     (clk),
      .in_write                (w_CMD_WRITE),
      .in_image_or_overlay     (w_CMD_IMAGE_OR_OVERLAY),
      .in_px_data              (w_CMD_PX_DATA),
      .in_addr                 (w_CMD_WR_ADDR),
      .in_rst                  (w_SUPER_RST),
      .out_synced_write_image  (w_SYNC_WR_IMAGE),
      .out_synced_write_overlay(w_SYNC_WR_OVERLAY),
      .out_synced_px_data      (w_SYNC_PX_DATA),
      .out_synced_addr         (w_SYNC_WR_ADDR),
      .out_synced_rst          (w_VRAM_RST)
  );


  SCREEN_CONTROL u_SCREEN_CONTROL (
      .clk                     (clk),
      .rst                     (w_SUPER_RST),
      .in_signal_PLANE_READY_MM(w_CONTROL_PLANE_READY),
      .in_signal_HUB75_WAITING (w_HUB75_WAITING),
      .in_signal_HUB75_ITER    (w_HUB75_ITER),
      .out_signal_BRIGHT_DIM   (w_BRIGH_DIM),
      .out_signal_SHIFT_PLANE  (w_CONTROL_SHIFT_PLANE),
      .out_PLANE_SELECT_MM     (w_CONTROL_PLANE_SELECT),
      .out_signal_CACHE        (w_CONTROL_CACHE),
      .out_signal_HUB75_INIT   (w_HUB75_INIT),
      .out_signal_HUB75_SHOW   (w_HUB75_SHOW),
      .out_signal_HUB75_RST    (w_HUB75_RST),
      .out_ROW                 (w_ROW)
  );

  read_memory_management u_read_memory_management (
      .clk              (clk),
      .rst              (w_HUB75_RST),
      .in_CACHE         (w_CONTROL_CACHE),
      .in_ROW           (w_ROW),
      .in_PLANE_SELECT  (w_CONTROL_PLANE_SELECT),
      .in_SHIFT_PLANE   (w_CONTROL_SHIFT_PLANE),
      .in_RGB01         (w_PLANES_CACHE_RGB01),
      .in_ROW0_DATA     (w_ROW0_DATA),
      .in_ROW1_DATA     (w_ROW1_DATA),
      .in_VRAM_DONE_READ(w_VRAM_SIGNAL),
      .out_PLANE_READY  (w_CONTROL_PLANE_READY),
      .out_PLANE_LOAD0  (w_PLANES_CACHE_LOAD0),
      .out_PLANE_LOAD1  (w_PLANES_CACHE_LOAD1),
      .out_PLANE_SHIFT  (w_PLANES_CACHE_SHIFT),
      .out_ROW_LOAD0    (w_ROW_CACHE_ROW_LOAD0),
      .out_ROW_LOAD1    (w_ROW_CACHE_ROW_LOAD1),
      .out_RGB0         (w_HUB75_RGB0),
      .out_RGB1         (w_HUB75_RGB1),
      .out_R            (w_PLANES_CACHE_RED),
      .out_G            (w_PLANES_CACHE_GREEN),
      .out_B            (w_PLANES_CACHE_BLUE),
      .out_ADDR         (w_MEM_MANG_ADDR),
      .out_RD           (w_MEM_MANG_RD)
  );
  HUB75 u_HUB75 (
      .clk              (clk),
      .rst              (w_HUB75_RST),
      .in_INIT          (w_HUB75_INIT),
      .in_RGB0          (w_HUB75_RGB0),
      .in_RGB1          (w_HUB75_RGB1),
      .in_ROW           (w_ROW),
      .in_SHOW          (w_HUB75_SHOW),
      .in_BRIGHT_DIM    (w_BRIGH_DIM),
      .ctl_CLOKER_ITER  (w_HUB75_ITER),
      .ctl_HUB75_WAITING(w_HUB75_WAITING),
      .w_RGB0           (to_screen_RGB0),
      .w_RGB1           (to_screen_RGB1),
      .w_SCREEN_CLOCK   (to_screen_CLK),
      .w_ABCDE          (to_screen_ABCDE),
      .w_LATCH          (to_screen_LATCH),
      .w_nOE            (to_screen_nOE)
  );
  planes_cache u_planes_cache (
      .clk      (clk),
      .in_R     (w_PLANES_CACHE_RED),
      .in_G     (w_PLANES_CACHE_GREEN),
      .in_B     (w_PLANES_CACHE_BLUE),
      .in_LOAD0 (w_PLANES_CACHE_LOAD0),
      .in_LOAD1 (w_PLANES_CACHE_LOAD1),
      .in_SHIFT (w_PLANES_CACHE_SHIFT),
      .out_RGB01(w_PLANES_CACHE_RGB01)
  );

  row_cache u_row_cache0 (
      .clk     (clk),
      .in_data (w_FRAME_DATA),
      .in_load (w_ROW_CACHE_ROW_LOAD0),
      .out_data(w_ROW0_DATA)
  );

  row_cache u_row_cache1 (
      .clk     (clk),
      .in_data (w_FRAME_DATA),
      .in_load (w_ROW_CACHE_ROW_LOAD1),
      .out_data(w_ROW1_DATA)
  );

  VRAM #(
      .HEX_FILE(IMAGE_FILE)
  ) u_VRAM_IMAGE (
      .clk        (clk),
      .rst        (w_VRAM_RST),
      .wr         (w_SYNC_WR_IMAGE),
      .wr_addr    (w_SYNC_WR_ADDR),
      .in_data    (w_SYNC_PX_DATA),
      .rd         (w_MEM_MANG_RD),
      .rd_addr    (w_MEM_MANG_ADDR),
      .out_data   (w_IMAGE_DATA),
      .out_charged(w_VRAM_IMAGE_SIGNAL)
  );

  VRAM #(
      .HEX_FILE(OVERLAY_FILE)
  ) u_VRAM_OVERLAY (
      .clk        (clk),
      .rst        (w_VRAM_RST),
      .wr         (w_SYNC_WR_OVERLAY),
      .wr_addr    (w_SYNC_WR_ADDR),
      .in_data    (w_SYNC_PX_DATA),
      .rd         (w_MEM_MANG_RD),
      .rd_addr    (w_MEM_MANG_ADDR),
      .out_data   (w_OVERLAY_DATA),
      .out_charged(w_VRAM_OVERLAY_SIGNAL)
  );

  VRAM #(
      .HEX_FILE(PALETTE_FILE)
  ) u_VROM_PALETTE (
      .clk        (clk),
      .rst        (w_VRAM_RST),
      .wr         (1'b0),
      .wr_addr    (12'b0),
      .in_data    (8'b0),
      .rd         (w_MEM_MANG_RD),
      .rd_addr    (w_MEM_MANG_ADDR),
      .out_data   (w_PALETTE_DATA),
      .out_charged(w_VRAM_PALETTE_SIGNAL)
  );

  multiplexor2x1 #(
      .IN_WIDTH(512)
  ) u_image_selection (
      .IN1    (w_PALETTE_DATA),
      .IN0    (w_IMAGE_DATA),
      .SELECT (w_CMD_IMAGE_SELECT),
      .MUX_OUT(w_MUX_SELECTED_IMAGE)
  );

  image_fusion u_image_fusion (
      .image_data  (w_MUX_SELECTED_IMAGE),
      .overlay_data(w_OVERLAY_DATA),
      .fusion_data (w_FRAME_DATA)
  );





endmodule
