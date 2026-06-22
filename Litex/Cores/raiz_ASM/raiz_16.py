from migen import *
from litex.soc.interconnect.csr import *
import os
src_dir = os.path.dirname(os.path.abspath(__file__))

class Raiz16(Module, AutoCSR):
    def __init__(self, platform):

        self._in_RR    = CSRStorage(16, description="Radicando (16 bits)")
        self._init = CSRStorage( 1, description="Pulso de inicio")

        self._out_R   = CSRStatus(16, description="Resultado (16 bits)")
        self._out_Q   = CSRStatus(16, description="Residuo (16 bits)")
        self._out_DONE = CSRStatus( 1, description="1 cuando terminó")

        self.specials += Instance("raiz_16",
            i_clk     = ClockSignal("sys"),
            i_rst     = ResetSignal("sys"),
            i_init = self._init.storage,
            i_in_RR       = self._in_RR.storage,
            o_out_R   = self._out_R.status,
            o_out_Q   = self._out_Q.status,
            o_out_DONE = self._out_DONE.status,
        )

        for src in ["../building_blocks/sumador.v", "../building_blocks/acumulador_restando.v" , "raiz_16.v", "lsrR.v", "aux.v", "lsrQA.v", "control_raiz.v"]: 
            platform.add_source(os.path.join(src_dir, src))