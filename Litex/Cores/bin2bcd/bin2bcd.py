from migen import *
from litex.soc.interconnect.csr import *
import os
src_dir = os.path.dirname(os.path.abspath(__file__))

class Bin2BCD(Module, AutoCSR):
    def __init__(self, platform):
        self._A      = CSRStorage(16, description="Entrada binaria (16 bits)")
        self._init   = CSRStorage( 1, description="Pulso de inicio")
        self._result = CSRStatus(20,  description="Resultado BCD (20 bits = 5 dígitos)")
        self._done   = CSRStatus( 1,  description="1 cuando terminó")

        self.specials += Instance("bin2bcd",
            i_clk    = ClockSignal("sys"),
            i_rst    = ResetSignal("sys"),
            i_init   = self._init.storage,
            i_A      = self._A.storage,
            o_result = self._result.status,
            o_done   = self._done.status,
        )
        for src in ["lsr4.v", "ctrl_b2b.v", "count.v", "mux2.v",
                    "reg_msb.v", "add_sub_c2.v", "bin2bcd.v"]:
            platform.add_source(os.path.join(src_dir, src))