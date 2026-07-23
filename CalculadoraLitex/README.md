### Calculadora con litex

Integracion de la calculadora en hardware realizada en Electrónica Digital 1 con el framework de litex para la generacion del SoC.

## Como ejecutar:

cd Cores

./colorlight_5a_75x.py --board=5a-75e --revision=8.2 --build

sudo openFPGALoader -c ft232RL --pins=0:3:4:1 -m ./build/colorlight_5a_75e/gateware/colorlight_5a_75e.bit

make -C firmware clean

make SERIAL=/dev/ttyUSB0 -C firmware litex_term

