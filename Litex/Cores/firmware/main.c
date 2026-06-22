#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <irq.h>
#include <uart.h>
#include <console.h>
#include <generated/csr.h>
void my_busy_wait(unsigned int ms)
{
  timer0_en_write(0);
  timer0_reload_write(0);
  timer0_load_write(CONFIG_CLOCK_FREQUENCY / 1000 * ms);
  timer0_en_write(1);
  timer0_update_value_write(1);
  while (timer0_value_read())
    timer0_update_value_write(1);
}

static int read_int(void)
{
  char buf[16];
  int i = 0;
  char c;

  while (1)
  {
    c = uart_read();

    if (c == '\r' || c == '\n')
    {
      buf[i] = '\0';
      printf("\n");
      break;
    }

    if (i < 15)
    {
      buf[i++] = c;
      printf("%c", c);
    }
  }

  int value = 0;
  int sign = 1;
  int j = 0;

  if (buf[0] == '-')
  {
    sign = -1;
    j = 1;
  }

  for (; buf[j] != '\0'; j++)
  {
    if (buf[j] >= '0' && buf[j] <= '9')
      value = value * 10 + (buf[j] - '0');
  }

  return sign * value;
}

static uint32_t hw_mult(uint32_t a, uint32_t b)
{
  mult0__A_write(a);
  mult0__B_write(b);

  mult0_init_write(1);
  mult0_init_write(0);

  while (mult0_done_read() == 0)
    ;

  return mult0_pp_read();
}

static uint32_t hw_div(uint32_t a, uint32_t b, uint32_t *resto)
{
  div0__A_write(a);
  div0__B_write(b);

  div0_init_in_write(1);
  div0_init_in_write(0);

  while (div0_done_read() == 0)
    ;

  *resto = div0__Q_read();

  return div0__R_read();
}

static uint32_t hw_sqrt(uint32_t a, uint32_t *resto)
{
  raiz0_in_RR_write(a);

  raiz0_init_write(1);
  raiz0_init_write(0);

  while (raiz0_out_DONE_read() == 0)
    ;

  *resto = raiz0_out_Q_read();

  return raiz0_out_R_read();
}

int main(void)
{
  uint32_t a, b;
  uint32_t resultado;
  uint32_t resto;
  int opcion;

  while (1)
  {
    printf("\n");
    printf("===== CALCULADORA HW =====\n");
    printf("1. Multiplicacion\n");
    printf("2. Division\n");
    printf("3. Raiz cuadrada\n");
    printf("Seleccione: ");

    opcion = read_int();

    switch (opcion)
    {
    case 1:

      printf("A: ");
      a = read_int();

      printf("B: ");
      b = read_int();

      resultado = hw_mult(a, b);

      printf("%lu * %lu = %lu\n",
             (unsigned long)a,
             (unsigned long)b,
             (unsigned long)resultado);
      break;

    case 2:

      printf("A: ");
      a = read_int();

      printf("B: ");
      b = read_int();

      if (b == 0)
      {
        printf("Error: division por cero\n");
        break;
      }

      resultado = hw_div(a, b, &resto);

      printf("%lu / %lu = %lu\n",
             (unsigned long)a,
             (unsigned long)b,
             (unsigned long)resultado);

      printf("Resto = %lu\n",
             (unsigned long)resto);
      break;

    case 3:

      printf("A: ");
      a = read_int();

      resultado = hw_sqrt(a, &resto);

      printf("sqrt(%lu) = %lu\n",
             (unsigned long)a,
             (unsigned long)resultado);

      printf("Resto = %lu\n",
             (unsigned long)resto);
      break;

    default:
      printf("Opcion invalida\n");
      break;
    }
  }
  return 0;
}
