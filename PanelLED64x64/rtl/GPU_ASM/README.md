# Documentación del modulo GPU
## Preliminar
### Requerimientos
- Manejo de pantalla 64x64 mediante HUB75.
- 8 bits por color para cada pixel
- Permitir modificación de la imagen mostrada
- Mostrar paleta de colores
- Soporte de overlay para imagenes temporales
- Sincronización a flanco único
### HUB75
El conector HUB75E utilizado por la matriz led utilizada consta de 16 pines que permiten ingresar a la pantalla el color (rojo,verde o azul) de cada pixel para 2 filas de forma simultanea. Los colores son ingresados por pines dedicados para cada color(R,G,B) y fila (superior, inferior) a un registro de corrimiento habilitado con su propio pin de reloj. Luego el color de cada led es "guardado" con otro pin dedicado de nombre latch para asi encender los leds con la señal nOE.
<img alt="Imagen puerto HUB75">

## Diseño conceptual
### Modulación 
La modulación permite controlar el brillo de los leds sin interferir con el circuito de potencia directamente mediante el encendido y apagado programado de el led. Los siguentes tipos de modulación tienen el mismo fundamento, el valor eficaz de una señal periodica.
#### PWM (Pulse Width Modulation)
La modulación de ancho de pulso (PWM por sus siglas en ingles) controla la intensidad de el led mediante el control de el tiempo que un pulso periodico mantiene el led encendido. Para esta modulación se utiliza un pulso al que se varia el ciclo util según se necesite, es util para emular diferentes voltajes a partir de una señal digital de algun voltaje. Para generar esta señal solo se necesita un contador que cambie el valor de la señal digital de bajo a alto segun se necesite, aunque se debe tener en cuenta que la freciencia debe ser suficiente para (>=1kHz) para que ojo humano no vea el parpadeo de el led.
#### BCM (Binary Code Modulation)
(1)[https://www.batsocks.co.uk/readme/p_art_bcm.htm] (2)[https://christian-marty.ch/electricThings/bitAngleModulation]
La modulación binaria es similar al PWM, sin embargo el control de el tiempo que esta encendido el led es determinado por una representación binaria, de cierta resolución (4bits, 8bits, etc), en la cual cada bit tiene un peso, un tiempo en el que estara encendido o apagado el led, que se duplica desde el bit menos significativo hasta el más significativo. Así el valor promedio de la señal es repartido entre varios pulsos de diferente duración.
#### Propuesta
Se propone el uso de BCM para lograr la resolución de color solicitada, debido a que no se puede controlar el encendido o apagado de el led, se tiene al registro de corrimiento, la señal latch y la señal nOE, de las cuales la señal nOE seria la unica variable en ancho de pulso. Por lo que se usara el concepto de "planos"(3)[https://news.sparkfun.com/2650] para definir la representación binaria de la potencia de el led. Se define completamente en la sección de codificación de color.
### Codificación de color
Existen varias formas de guardar la información sobre el color.

### Parametros de diseño
- Codificación RRRGGGBB para los colores
- Modulación binaria para la percepción de color
- Disponibilidad de escritura en memoria >= 90% (1- (t no disponible/t disponible))
- Frecuencia de dibujado de toda la pantalla >= 60Hz
- Escritura sincrona en flanco positivo
- Escritura induvidual de pixel según fila, columna
