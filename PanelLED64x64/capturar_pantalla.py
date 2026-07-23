#!/usr/bin/env python3
"""
Requisitos:
  pip install pyserial pillow --break-system-packages
  sudo dnf install gnome-screenshot

Uso:
  python3 capturar_pantalla.py /dev/ttyUSB1 115200

Controles:
  Arrastrar el marco rojo (con click izquierdo)  -> mover el recuadro  
  Boton Enviar   -> capturar y mandar
  Boton Salir    -> cerrar

"""
import os
import sys
import time
import subprocess
import tempfile
import tkinter as tk

import serial
from PIL import Image

from send_frame_serial import pack_rgb332, IMG_SYNC_BYTE, ROW_INVERT, COL_INVERT

TMP_CAPTURE_PATH = os.path.join(tempfile.gettempdir(), "panel_led_capture.png")


def gnome_screenshot_area(x, y, width, height, out_path=TMP_CAPTURE_PATH):
    full_path = out_path.replace(".png", "_full.png")

    result = subprocess.run(
        ["gnome-screenshot", "-f", full_path],
        capture_output=True, text=True, timeout=5,
    )
    if result.returncode != 0:
        raise RuntimeError(
            f"gnome-screenshot fallo: {result.stderr.strip() or result.stdout.strip()}\n"
            f"Verifica que este instalado: sudo dnf install gnome-screenshot"
        )

    full_img = Image.open(full_path)
    cropped = full_img.crop((x, y, x + width, y + height))
    cropped.save(out_path)
    return out_path


def build_frame_bytes_from_image(img):
    img = img.convert("RGB").resize((64, 64), Image.NEAREST)
    px = img.load()
    data = bytearray()
    for row in range(64):
        r_addr = (63 - row) if ROW_INVERT else row
        for col in range(64):
            c_addr = (63 - col) if COL_INVERT else col
            r, g, b = px[c_addr, r_addr]
            data.append(pack_rgb332(r, g, b))
    return bytes(data)


BOX_SIZE = 64    
BORDER = 1        


class SelectorApp:
    def __init__(self, ser):
        self.ser = ser
        self.x, self.y = 100, 100

        self.root = tk.Tk()
        self.root.withdraw()


        self.bars = {
            "top": self._make_bar(),
            "bottom": self._make_bar(),
            "left": self._make_bar(),
            "right": self._make_bar(),
        }

        self.panel = tk.Toplevel(self.root)
        self.panel.attributes("-topmost", True)
        self.panel.overrideredirect(True)
        tk.Button(self.panel, text="Enviar", command=self.capture_and_send).pack(side="left")
        tk.Button(self.panel, text="Salir", command=self.quit).pack(side="left")

        self._drag_start = None
        self._reposition()

        for bar in self.bars.values():
            self._bind_widget(bar)
        self._bind_widget(self.panel)

        self.bars["top"].focus_force()

    def _make_bar(self):
        win = tk.Toplevel(self.root)
        win.attributes("-topmost", True)
        win.overrideredirect(True)
        canvas = tk.Canvas(win, bg="red", highlightthickness=0)
        canvas.pack(fill="both", expand=True)
        win.canvas = canvas
        return win

    def _bind_widget(self, widget):
        target = getattr(widget, "canvas", widget)
        target.bind("<ButtonPress-1>", self._start_drag)
        target.bind("<B1-Motion>", self._on_drag)
        widget.bind("<Return>", lambda e: self.capture_and_send())
        widget.bind("<space>", lambda e: self.capture_and_send())
        widget.bind("<Escape>", lambda e: self.quit())
        widget.bind("<Up>", lambda e: self._move(0, -1))
        widget.bind("<Down>", lambda e: self._move(0, 1))
        widget.bind("<Left>", lambda e: self._move(-1, 0))
        widget.bind("<Right>", lambda e: self._move(1, 0))
        widget.bind("<Shift-Up>", lambda e: self._move(0, -10))
        widget.bind("<Shift-Down>", lambda e: self._move(0, 10))
        widget.bind("<Shift-Left>", lambda e: self._move(-10, 0))
        widget.bind("<Shift-Right>", lambda e: self._move(10, 0))

    def _start_drag(self, event):
        self._drag_start = (event.x_root, event.y_root, self.x, self.y)

    def _on_drag(self, event):
        if self._drag_start is None:
            return
        mx0, my0, x0, y0 = self._drag_start
        self._move_to(x0 + (event.x_root - mx0), y0 + (event.y_root - my0))

    def _move(self, dx, dy):
        self._move_to(self.x + dx, self.y + dy)

    def _move_to(self, x, y):
        self.x, self.y = int(x), int(y)
        self._reposition()

    def _reposition(self):
        x, y, s, b = self.x, self.y, BOX_SIZE, BORDER
        self.bars["top"].geometry(f"{s}x{b}+{x}+{y}")
        self.bars["bottom"].geometry(f"{s}x{b}+{x}+{y + s - b}")
        self.bars["left"].geometry(f"{b}x{s}+{x}+{y}")
        self.bars["right"].geometry(f"{b}x{s}+{x + s - b}+{y}")
        self.panel.geometry(f"+{x}+{max(0, y - 35)}")

    def capture_and_send(self):
        x, y, size = self.x, self.y, BOX_SIZE
        for bar in self.bars.values():
            bar.withdraw()
        self.panel.withdraw()
        self.root.update()
        time.sleep(0.08)

        try:
            path = gnome_screenshot_area(x, y, size, size)
            img = Image.open(path)
        except Exception as e:
            for bar in self.bars.values():
                bar.deiconify()
            self.panel.deiconify()
            print(f"[ERROR] {e}")
            return

        for bar in self.bars.values():
            bar.deiconify()
        self.panel.deiconify()

        frame = build_frame_bytes_from_image(img)
        self.ser.write(bytes([IMG_SYNC_BYTE]))
        self.ser.write(frame)
        self.ser.flush()
        print(f"[OK] Capturado {size}x{size}px en ({x},{y}) -> enviado ({len(frame)} bytes)")

    def quit(self):
        self.root.destroy()

    def run(self):
        self.root.mainloop()


def main():
    if len(sys.argv) != 3:
        print("Uso: python3 capturar_pantalla.py <puerto> <baudrate>")
        print("Ej:  python3 capturar_pantalla.py /dev/ttyUSB1 115200")
        sys.exit(1)

    port, baud = sys.argv[1], int(sys.argv[2])

    with serial.Serial(port, baud, timeout=2) as ser:
        time.sleep(0.05)
        if ser.in_waiting:
            print(ser.read(ser.in_waiting).decode(errors="replace"))

        SelectorApp(ser).run()

    print("Puerto cerrado.")


if __name__ == "__main__":
    main()