import sys
import time
import serial
from PIL import Image

IMG_SYNC_BYTE = 0xAA
ROW_INVERT = False
COL_INVERT = False


def pack_rgb332(r, g, b):
    r3 = (r >> 5) & 0b111
    g3 = (g >> 5) & 0b111
    b2 = (b >> 6) & 0b11
    return (r3 << 5) | (g3 << 2) | b2


def build_frame_bytes(img_path):
    img = Image.open(img_path).convert("RGB").resize((64, 64), Image.NEAREST)
    px = img.load()
    data = bytearray()
    for row in range(64):
        r_addr = (63 - row) if ROW_INVERT else row
        for col in range(64):
            c_addr = (63 - col) if COL_INVERT else col
            r, g, b = px[c_addr, r_addr]
            data.append(pack_rgb332(r, g, b))
    return bytes(data)


def send_image(ser, img_path):
    frame = build_frame_bytes(img_path)
    ser.write(bytes([IMG_SYNC_BYTE]))
    ser.write(frame)
    ser.flush()
    print(f"[OK] {img_path}: {len(frame)} bytes de pixel enviados")




def main():

    port, baud = sys.argv[1], int(sys.argv[2])
    images = sys.argv[3:]

    with serial.Serial(port, baud, timeout=2) as ser:
        drain_firmware_messages(ser)

        if images:
            # Modo lote: manda todas las imagenes que vinieron como argumento
            for img_path in images:
                send_image(ser, img_path)
                drain_firmware_messages(ser)
                time.sleep(0.1)
        else:
            # Modo interactivo: el puerto queda abierto y se puede mandar
            # imagen tras imagen sin volver a correr el script
            print(f"Conectado a {port} @ {baud}. Puerto abierto una sola vez.")
            print("Escribe la ruta de una imagen y Enter para mandarla al panel.")
            print("Enter vacio o 'q' para salir.\n")
            while True:
                try:
                    path = input("Imagen> ").strip()
                except (EOFError, KeyboardInterrupt):
                    print()
                    break
                if not path or path.lower() == "q":
                    break
                try:
                    send_image(ser, path)
                    drain_firmware_messages(ser)
                except FileNotFoundError:
                    print(f"[ERROR] No existe el archivo: {path}")
                except Exception as e:
                    print(f"[ERROR] {e}")

    print("Puerto cerrado.")


if __name__ == "__main__":
    main()