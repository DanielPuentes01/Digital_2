# FPGA Ethernet LED Matrix Display FM6363

## Universidad Nacional De Colombia - Electrónica Digital II

## Autores

*Daniel Santiago Puentes Villabona - 1052378730*

*Samuel Felipe Hernández Herreño - 102740044*

## Descripción General

Este proyecto implementa un sistema basado en FPGA para visualizar el contenido de una seccion de una pantalla de computador sobre un panel LED RGB. La plataforma utiliza LiteX para generar un System-on-Chip (SoC) que integra un procesador, memoria y periféricos, permitiendo la recepción de datos mediante Ethernet y el control del hardware de visualización.

El objetivo final es desarrollar una aplicación de escritorio que permita seleccionar una región de la pantalla del computador, similar a una herramienta de captura, escalarla a la resolución del panel y transmitirla en tiempo real a través de Ethernet. En la FPGA, el procesador LiteX será el encargado de recibir los paquetes de red y actualizar un framebuffer interno, mientras que un controlador implementado en Verilog realizará el refresco continuo del panel LED, incluyendo la inicialización del controlador FM6363.

## Características

- Arquitectura basada en un SoC generado con LiteX.
- Comunicación entre el computador y la FPGA mediante Ethernet.
- Captura y transmisión de una región seleccionada de la pantalla del computador.
- Controlador completamente desarrollado en Verilog.
- Inicialización automática de paneles con controlador FM6363.
- Framebuffer interno para almacenamiento de la imagen.
- Generación de señales RGB, CLK, LAT, OE y direccionamiento de filas.
- Arquitectura modular para facilitar la simulación y reutilización de componentes.
- Simulación RTL y post-síntesis del controlador.


## Arquitectura del Sistema 

<img title="Diagrama de Arquitectura del Sistema" src=".PanelPWM/docs/arquitectura.png" height="400">

## Organización del proyecto
``` 
./PanelPWM
  ├── dependencies/           # Módulos auxiliares del controlador HUB75
  │   ├── test_benches/             # Testbenches de los modulos auxiliares
  ├── docs/                   # Imágenes y documentación
  ├── simulation/
  │   ├── simple/             # Simulaciones RTL
  │   └── post_synth/         # Simulaciones post-síntesis
  ├── test_benches/           # Testbenches del modulo principal
  ├── panel_pwm.v             # Módulo principal del controlador
  └── control_panel_pwm.v     # Máquina de estados principal
./building_blocks/            # Algunos otros modulos basicos utilizados (contadores, comparadores, registros, etc...)
```

## Hardware

El sistema fue desarrollado utilizando una FPGA Lattice ECP5 conectada a un panel LED RGB HUB75 con controlador FM6363.

### Componentes

- FPGA Colorlight 5A-75B (Lattice ECP5)
- Panel LED HUB75
- Controlador FM6363
- Comunicación Ethernet

## Arquitectura del Controlador

```
panel_pwm
│
├── control_panel_pwm
│
├── sendcfg
│
├── send_frame
│     └── pixel_reader
│           └── framebuffer
│
├── latch_command
│
└── four_clk
```

De acuerdo al datasheet del controlador FM6363 es necesario seguir una serie de pasos para tanto inicializar los controladores, como para mandar una serie de datos a traves de los pines RGB del HUB75. Gracias a los modulos sendcfg, latch_command y four_clk se puede realizar la inicialización de los controladores. Ademas, con el modulo send_frame se logra realizar el envio de datos RGB como se especifica en el datasheet. Como es necesario enviar varios distintos comandos en distintos momentos es necesario implementar una maquina de estados que active un modulo cuando sea necesario, y, cuando este modulo termine su operación, active el siguiente, esto se implementa gracias al modulo control_panel_pwm.

### Modulo sendcfg
Este modulo se utiliza para enviar un registro de 16 bits de configuracion por los pines RGB a todos los controladores FM6363 del panel LED utilizado.
Los registros de configuracion del FM6363