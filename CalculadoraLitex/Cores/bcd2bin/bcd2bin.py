from migen import *
from litex.soc.interconnect.csr import *
import os
src_dir = os.path.dirname(os.path.abspath(__file__))
bin2bcd_dir = os.path.join(os.path.dirname(src_dir), "bin2bcd")

class BCD2Bin(Module, AutoCSR):
    def __init__(self, platform):
        self._A      = CSRStorage(20, description="Entrada BCD (20 bits)")
        self._init   = CSRStorage( 1, description="Pulso de inicio")
        self._result = CSRStatus(16,  description="Resultado binario (16 bits)")
        self._done   = CSRStatus( 1,  description="1 cuando terminó")

        self.specials += Instance("bcd2bin",
            i_clk    = ClockSignal("sys"),
            i_rst    = ResetSignal("sys"),
            i_init   = self._init.storage,
            i_A      = self._A.storage,
            o_result = self._result.status,
            o_done   = self._done.status,
        )
        # Archivos exclusivos de bcd2bin
        for src in ["rsr4.v", "ctrl_bcd2b.v", "bcd2bin.v"]:
            platform.add_source(os.path.join(src_dir, src))
        # Archivos compartidos con bin2bcd (incluir solo una vez)
        for src in ["count.v", "mux2.v", "reg_msb.v", "add_sub_c2.v"]:
            platform.add_source(os.path.join(bin2bcd_dir, src))
