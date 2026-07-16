from migen import *
from litex.soc.interconnect.csr import *
import os

src_dir = os.path.dirname(os.path.abspath(__file__))
objs = [os.path.join(src_dir,"../rtl/GPU_ASM/GPU.v")]

class ScreenController64x64(Module, AutoCSR):
    def __init__(self,platform, out_pins):
        self.we = we = CSRStorage(1)
        self.px_data_in = px_data = CSRStorage(8)
        self.column = column = CSRStorage(6)
        self.row = row = CSRStorage(6)
        self.image_or_palette = img_signal1 = CSRConstant(0)
        self.image_or_overlay = img_signal2 = CSRConstant(0)

        self.specials += Instance("GPU",
                i_clk = ClockSignal("sys"), # Reloj de 25 MHz
                i_rst_n = ResetSignal("sys"),
                i_write = we.storage,
                i_px_data = px_data.storage,
                i_column = column.storage,
                i_row = row.storage,
                i_image_palette = img_signal1.constant,
                i_image_overlay = img_signal2.constant,
                o_to_screen_RGB0 = out_pins.to_screen_RGB0,
                o_to_screen_RGB1 = out_pins.to_screen_RGB1,
                o_to_screen_CLK = out_pins.to_screen_CLK,
                o_to_screen_ABCDE = out_pins.to_screen_ABCDE,
                o_to_screen_LATCH = out_pins.to_screen_LATCH,
                o_to_screen_nOE = out_pins.to_screen_nOE
        )
        join = os.path.join(src_dir,"../rtl/GPU_ASM/dependencies")
        if os.path.exists(join):
            for entry in os.scandir(join):
                if entry.is_dir():
                    for file in os.scandir(entry.path):
                        if file.is_file() and file.name.endswith(".v"):
                            objs.append(file.path)
    
        for file in objs:
            platform.add_source(os.path.join(src_dir,file))

        platform.add_source_dir(os.path.join(src_dir,"../rtl/building_blocks"))
