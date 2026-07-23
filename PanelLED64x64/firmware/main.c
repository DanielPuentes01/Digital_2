#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <irq.h>
#include <uart.h>
#include <console.h>
#include <generated/csr.h>

#define IMG_SYNC_BYTE 0xAA
#define IMG_WIDTH 64
#define IMG_HEIGHT 64

/* Escribe un pixel en la VRAM de GPU.v via los CSR de disp0.
 * px_byte se asume empaquetado RGB332 (ajustar si el packing real
 * de COMMAND_DECODER.v es distinto). */
static void disp0_write_pixel(uint32_t col, uint32_t row, uint8_t px_byte)
{
  disp0_column_write(col);
  disp0_row_write(row);
  disp0_px_data_in_write(px_byte);
  disp0_we_write(1); /* flanco de subida -> pulso de escritura */
  disp0_we_write(0);
}

static void receive_and_display_image(void)
{
  uint8_t px;

  do
  {
    px = (uint8_t)uart_read();
  } while (px != IMG_SYNC_BYTE);

  for (uint32_t row = 0; row < IMG_HEIGHT; row++)
  {
    for (uint32_t col = 0; col < IMG_WIDTH; col++)
    {
      px = (uint8_t)uart_read();
      disp0_write_pixel(col, row, px);
    }
  }

  printf("Frame recibido (%d x %d px)\n", IMG_WIDTH, IMG_HEIGHT);
}

int main(void)
{
  uart_init();

  printf("\n");
  printf("===== FIRMWARE PANEL LED 64x64 =====\n");
  printf("Esperando frames por UART (sync=0x%02X, %dx%d bytes)...\n",
         IMG_SYNC_BYTE, IMG_WIDTH, IMG_HEIGHT);

  while (1)
  {
    receive_and_display_image();
  }

  return 0;
}