#!/usr/bin/env python3
"""
capture_stream.py

Captura una región de pantalla, la reescala a 64x64 y la envía
a la matriz LED del Colorlight 5A-75E vía Etherbone (LiteX RemoteClient).

Requisitos en la PC:
    pip install mss pillow
    (litex debe estar ya instalado, lo usas para el proyecto del board)

Requisitos en el FPGA:
    - Habilitar Etherbone en colorlight_5a_75x.py (add_etherbone en vez de
      add_ethernet) y reconstruir/cargar el bitstream con --with-etherbone.

Uso típico:
    python3 capture_stream.py --host 192.168.1.50 --left 0 --top 0 \
        --width 640 --height 640 --fps 3
"""

import time
import argparse
import mss
from PIL import Image
from litex.tools.remote import moteClient
,



def rgb_to_pixel(r, g, b):

    return (r & 0xE0) | ((g & 0xE0) >> 3) | ((b & 0xC0) >> 6)


def write_pixel(bus, col, row, pixel):
    bus.regs.disp0_column.write(col)
    bus.regs.disp0_row.write(row)
    bus.regs.disp0_px_data_in.write(pixel)
    bus.regs.disp0_we.write(1)
    bus.regs.disp0_we.write(0)


def capture_region(sct, monitor, size=(64, 64)):
    img = sct.grab(monitor)
    pil_img = Image.frombytes("RGB", img.size, img.rgb)
    return pil_img.resize(size, Image.LANCZOS)


def main():
    parser = argparse.ArgumentParser(
        description="Screen mirror -> matriz LED 64x64 vía Etherbone"
    )
    parser.add_argument("--host", default="192.168.1.50", help="IP del board (eth_ip)")
    parser.add_argument("--port", type=int, default=1234, help="Puerto UDP etherbone")
    parser.add_argument("--csr-csv", default=None, help="Ruta a csr.csv generado por el build (opcional pero recomendado)")
    parser.add_argument("--left", type=int, default=0)
    parser.add_argument("--top", type=int, default=0)
    parser.add_argument("--width", type=int, default=640, help="Ancho de la región a capturar en px de pantalla")
    parser.add_argument("--height", type=int, default=640, help="Alto de la región a capturar en px de pantalla")
    parser.add_argument("--fps", type=float, default=3.0, help="FPS objetivo. Empieza bajo, ver notas de rendimiento.")
    parser.add_argument("--diff-only", action="store_true", help="Solo reenvía pixeles que cambiaron respecto al frame anterior")
    args = parser.parse_args()

    bus = RemoteClient(host=args.host, port=args.port, csr_csv=args.csr_csv)
    bus.open()

    monitor = {"left": args.left, "top": args.top, "width": args.width, "height": args.height}
    prev_frame = None
    frame_interval = 1.0 / args.fps

    print(f"Conectado a {args.host}:{args.port}, capturando región {monitor}")
    try:
        with mss.mss() as sct:
            while True:
                t0 = time.time()
                frame = capture_region(sct, monitor)
                pixels = frame.load()

                sent = 0
                new_frame = [[0] * 64 for _ in range(64)] if args.diff_only else None

                for row in range(64):
                    for col in range(64):
                        r, g, b = pixels[col, row]
                        px = rgb_to_pixel(r, g, b)

                        if args.diff_only:
                            new_frame[row][col] = px
                            if prev_frame is not None and prev_frame[row][col] == px:
                                continue

                        write_pixel(bus, col, row, px)
                        sent += 1

                if args.diff_only:
                    prev_frame = new_frame

                elapsed = time.time() - t0
                print(f"Frame en {elapsed*1000:.0f} ms ({sent} pixeles enviados)")
                sleep_t = frame_interval - elapsed
                if sleep_t > 0:
                    time.sleep(sleep_t)
    except KeyboardInterrupt:
        print("Detenido por el usuario.")
    finally:
        bus.close()


if __name__ == "__main__":
    main()