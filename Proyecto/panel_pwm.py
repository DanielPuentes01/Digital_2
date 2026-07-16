from migen import *
from litex.soc.interconnect.csr import *

import os

src_dir = os.path.dirname(os.path.abspath(__file__))

panel_dir = os.path.join(src_dir, "PanelASM")
dep_dir   = os.path.join(panel_dir, "dependencies")
bb_dir    = os.path.join(src_dir, "building_blocks")


class PanelPWM(Module, AutoCSR):
    def __init__(self, platform):

        # ------------------------------------------------------------
        # CSR: control del core
        # ------------------------------------------------------------

        self._init = CSRStorage(
            1,
            description="Inicia el envío del framebuffer"
        )

        self._done = CSRStatus(
            1,
            description="1 cuando termina un frame"
        )

        # ------------------------------------------------------------
        # CSR: escritura indirecta de píxeles (48 bits) desde el host
        # ------------------------------------------------------------
        # Protocolo: el host escribe _addr, _data_lo y _data_hi (en
        # cualquier orden), y por último escribe _write (cualquier
        # valor) para hacer el commit del píxel en memoria.

        self._addr = CSRStorage(
            13,
            description="Dirección lógica del píxel (0-8191). "
                        "El bit 12 selecciona mitad superior/inferior "
                        "del panel."
        )

        self._data_lo = CSRStorage(
            32,
            description="Bits [31:0] del píxel a escribir"
        )

        self._data_hi = CSRStorage(
            16,
            description="Bits [47:32] del píxel a escribir"
        )

        # Escribir cualquier valor acá hace commit del píxel
        # (_addr, _data_lo, _data_hi) en memoria.
        self._write = CSR(name="write")

        # ------------------------------------------------------------
        # Señales entre LiteX y panel_pwm.v
        # ------------------------------------------------------------

        self.addr1  = Signal(13)
        self.addr2  = Signal(13)

        self.pixel1 = Signal(48)
        self.pixel2 = Signal(48)

        self.rgb1   = Signal(3)
        self.rgb2   = Signal(3)

        self.oe     = Signal()
        self.w_clk  = Signal()
        self.latch  = Signal()
        self.abcde  = Signal(5)

        # ------------------------------------------------------------
        # Framebuffer (reemplazo de framebuffer.v)
        # ------------------------------------------------------------
        # addr1 siempre cae en [0, 4095] (mitad de arriba del panel) y
        # addr2 siempre en [4096, 8191] (mitad de abajo), con
        # addr2[11:0] == addr1[11:0] siempre (ver pixel_reader.v). Por
        # eso se modelan como dos BRAM independientes de 4096 x 48
        # bits, cada una con puerto de lectura (para el core Verilog)
        # y puerto de escritura (para el host vía CSR). Esto respeta
        # el límite de 2 puertos por bloque de BRAM del ECP5.
        #
        # Nota de timing: send_frame.v ya tiene un ciclo de margen
        # entre el cambio de dirección (ASSIGN_RGB) y el consumo del
        # dato (CLKUP1), que coincide exactamente con la latencia de
        # lectura síncrona de una BRAM. No se necesita retiming extra.

        mem_depth = 4096
        mem_a = Memory(48, mem_depth, name="panel_fb_upper")  # addr1
        mem_b = Memory(48, mem_depth, name="panel_fb_lower")  # addr2

        port_a_rd = mem_a.get_port(write_capable=False, async_read=False)
        port_b_rd = mem_b.get_port(write_capable=False, async_read=False)
        port_a_wr = mem_a.get_port(write_capable=True,  async_read=False)
        port_b_wr = mem_b.get_port(write_capable=True,  async_read=False)

        self.specials += mem_a, mem_b, port_a_rd, port_b_rd, port_a_wr, port_b_wr

        # Lectura para el core Verilog
        self.comb += [
            port_a_rd.adr.eq(self.addr1[0:12]),
            self.pixel1.eq(port_a_rd.dat_r),

            port_b_rd.adr.eq(self.addr2[0:12]),
            self.pixel2.eq(port_b_rd.dat_r),
        ]

        # Escritura desde el host: un pulso de _write.re hace commit
        # del píxel armado en (_addr, _data_lo, _data_hi).
        sel_upper = ~self._addr.storage[12]
        sel_lower = self._addr.storage[12]
        wr_data   = Cat(self._data_lo.storage, self._data_hi.storage)

        self.comb += [
            port_a_wr.adr.eq(self._addr.storage[0:12]),
            port_b_wr.adr.eq(self._addr.storage[0:12]),

            port_a_wr.dat_w.eq(wr_data),
            port_b_wr.dat_w.eq(wr_data),

            port_a_wr.we.eq(self._write.re & sel_upper),
            port_b_wr.we.eq(self._write.re & sel_lower),
        ]

        # ------------------------------------------------------------
        # Instancia del controlador Verilog
        # ------------------------------------------------------------

        self.specials += Instance(
            "panel_pwm",

            i_clk   = ClockSignal("sys"),
            i_n_rst = ~ResetSignal("sys"),

            i_init  = self._init.storage,

            i_pixel1 = self.pixel1,
            i_pixel2 = self.pixel2,

            o_addr1 = self.addr1,
            o_addr2 = self.addr2,

            o_RGB1 = self.rgb1,
            o_RGB2 = self.rgb2,

            o_OE    = self.oe,
            o_w_clk = self.w_clk,
            o_latch = self.latch,
            o_ABCDE = self.abcde,

            o_done = self._done.status
        )

        # ------------------------------------------------------------
        # Añadir todos los archivos Verilog (sin framebuffer.v)
        # ------------------------------------------------------------

        sources = [

            # Top
            os.path.join(panel_dir, "panel_pwm.v"),
            os.path.join(panel_dir, "control_panel_pwm.v"),

            # Dependencias
            os.path.join(dep_dir, "send_frame.v"),
            os.path.join(dep_dir, "pixel_reader.v"),
            os.path.join(dep_dir, "sendcfg.v"),
            os.path.join(dep_dir, "control_sendcfg.v"),
            os.path.join(dep_dir, "control_send_frame.v"),
            os.path.join(dep_dir, "control_four_clk.v"),
            os.path.join(dep_dir, "control_latch_command.v"),
            os.path.join(dep_dir, "four_clk.v"),
            os.path.join(dep_dir, "latch_command.v"),

            # Building blocks
            os.path.join(bb_dir, "acumulador.v"),
            os.path.join(bb_dir, "acumulador_restando.v"),
            os.path.join(bb_dir, "comp.v"),
            os.path.join(bb_dir, "multiplexor2x1.v"),
            os.path.join(bb_dir, "LSR.v"),
            os.path.join(bb_dir, "RSR.v"),
        ]

        for src in sources:
            platform.add_source(src)