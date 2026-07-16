"""
Testbench de simulación (sin hardware, sin Verilator) para la lógica
de framebuffer de panel_pwm.py: CSR -> memoria dual (mem_a / mem_b).

Este módulo NO instancia el Verilog "panel_pwm" (Migen no puede
simularlo sin un backend tipo Verilator/cocotb). En cambio, replica
exactamente el bloque de memoria + CSR de PanelPWM de forma aislada,
con addr1/addr2 como Signals normales que el testbench maneja a mano
(en vez de venir de la caja negra Verilog).

Si en algún momento cambiás la lógica de memoria en panel_pwm.py,
actualizá el bloque "FramebufferOnly" acá abajo para que siga
reflejando exactamente lo mismo.

Correr con:  python3 test_panel_fb.py
"""

from migen import *
from litex.soc.interconnect.csr import *


class FramebufferOnly(Module, AutoCSR):
    """Copia exacta de la lógica de memoria+CSR de PanelPWM,
    sin el Instance de Verilog ni platform.add_source."""

    def __init__(self):
        self._addr = CSRStorage(13, name="addr")
        self._data_lo = CSRStorage(32, name="data_lo")
        self._data_hi = CSRStorage(16, name="data_hi")
        self._write = CSR(name="write")

        self.addr1 = Signal(13)
        self.addr2 = Signal(13)
        self.pixel1 = Signal(48)
        self.pixel2 = Signal(48)

        mem_depth = 4096
        mem_a = Memory(48, mem_depth, name="panel_fb_upper")
        mem_b = Memory(48, mem_depth, name="panel_fb_lower")

        port_a_rd = mem_a.get_port(write_capable=False, async_read=False)
        port_b_rd = mem_b.get_port(write_capable=False, async_read=False)
        port_a_wr = mem_a.get_port(write_capable=True,  async_read=False)
        port_b_wr = mem_b.get_port(write_capable=True,  async_read=False)

        self.specials += mem_a, mem_b, port_a_rd, port_b_rd, port_a_wr, port_b_wr

        self.comb += [
            port_a_rd.adr.eq(self.addr1[0:12]),
            self.pixel1.eq(port_a_rd.dat_r),

            port_b_rd.adr.eq(self.addr2[0:12]),
            self.pixel2.eq(port_b_rd.dat_r),
        ]

        sel_upper = ~self._addr.storage[12]
        sel_lower = self._addr.storage[12]
        wr_data = Cat(self._data_lo.storage, self._data_hi.storage)

        self.comb += [
            port_a_wr.adr.eq(self._addr.storage[0:12]),
            port_b_wr.adr.eq(self._addr.storage[0:12]),

            port_a_wr.dat_w.eq(wr_data),
            port_b_wr.dat_w.eq(wr_data),

            port_a_wr.we.eq(self._write.re & sel_upper),
            port_b_wr.we.eq(self._write.re & sel_lower),
        ]


def write_pixel(dut, addr, hi, lo):
    yield dut._addr.storage.eq(addr)
    yield dut._data_hi.storage.eq(hi)
    yield dut._data_lo.storage.eq(lo)
    yield  # dejar que se propaguen los valores

    yield dut._write.re.eq(1)
    yield  # pulso de commit (1 ciclo)
    yield dut._write.re.eq(0)
    yield


def tb(dut):
    ok = True

    def check(label, sig, expected):
        nonlocal ok
        val = yield sig
        status = "OK " if val == expected else "FAIL"
        if val != expected:
            ok = False
        print(f"[{status}] {label}: got=0x{val:012x} expected=0x{expected:012x}")

    # addr1/addr2 fijos en 0 -> leen la posición local 0 de cada memoria
    yield dut.addr1.eq(0)
    yield dut.addr2.eq(0)
    yield

    # --- Caso 1: escribir en mem_a (addr lógico=0, bit12=0) -> pixel1
    rojo = (0xFFFF << 32) | 0x00000000
    yield from write_pixel(dut, 0x0000, 0xFFFF, 0x00000000)
    for _ in range(2):
        yield
    yield from check("pixel1 (mem_a, addr=0, rojo)", dut.pixel1, rojo)

    # --- Caso 2: escribir en mem_b (addr lógico=0x1000=4096, bit12=1) -> pixel2
    verde = (0x0000 << 32) | 0xFFFF0000
    yield from write_pixel(dut, 0x1000, 0x0000, 0xFFFF0000)
    for _ in range(2):
        yield
    yield from check("pixel2 (mem_b, addr=4096, verde)", dut.pixel2, verde)

    # --- Caso 3: reescribir addr=0 con otro valor
    blanco = (0xFFFF << 32) | 0xFFFFFFFF
    yield from write_pixel(dut, 0x0000, 0xFFFF, 0xFFFFFFFF)
    for _ in range(2):
        yield
    yield from check("pixel1 (mem_a, addr=0, blanco tras rewrite)", dut.pixel1, blanco)

    # --- Caso 4: escribir addr=0 pero SIN pulsar _write -> no debe cambiar
    yield dut._addr.storage.eq(0x0000)
    yield dut._data_hi.storage.eq(0x1234)
    yield dut._data_lo.storage.eq(0x89ABCDEF)
    for _ in range(3):
        yield
    yield from check("pixel1 sin pulso _write (debe seguir en blanco)", dut.pixel1, blanco)

    # --- Caso 5: confirmar independencia mem_a / mem_b (escribir addr=0
    # no debe afectar lo que ya está en mem_b)
    yield from check("pixel2 no afectado por escritura en mem_a", dut.pixel2, verde)

    print("\n>>> RESULTADO:", "TODO OK" if ok else "HAY FALLAS")


if __name__ == "__main__":
    dut = FramebufferOnly()
    run_simulation(dut, tb(dut), vcd_name="test_panel_fb.vcd")