from migen import *
from litex.soc.interconnect.csr import *
import os
src_dir = os.path.dirname(os.path.abspath(__file__))

class Div16(Module, AutoCSR):
    def __init__(self, platform):

        self._A    = CSRStorage(16, description="Dividendo A (16 bits)")
        self._B    = CSRStorage(16, description="Divisor B (16 bits)")
        self._init_in = CSRStorage( 1, description="Pulso de inicio")

        self._R   = CSRStatus(16, description="Resultado (16 bits)")
        self._Q   = CSRStatus(16, description="Residuo (16 bits)")
        self._done = CSRStatus( 1, description="1 cuando terminó")

        self.specials += Instance("div_16",
            i_clk     = ClockSignal("sys"),
            i_rst     = ResetSignal("sys"),
            i_init_in = self._init_in.storage,
            i_A       = self._A.storage,
            i_B       = self._B.storage,
            o_R   = self._R.status,
            o_Q   = self._Q.status,
            o_done = self._done.status,
        )

        for src in ["../building_blocks/sumador.v", "../building_blocks/acumulador_restando.v" , "div_16.v", "lsr_div.v", "control_div.v"]: 
            platform.add_source(os.path.join(src_dir, src))