#!/bin/bash

# --- Configuración General ---
PERFIL="Placa-Desarrollo"
IP_PC="192.168.1.10/24"
IP_PLACA="192.168.1.50"
INTERFAZ="enp3s0f3u1u1" # IMPORTANTE: Cambia esto por tu puerto Ethernet real

# Leemos la variable de entorno MODO_PLACA
# Puede tomar los valores: "setup", "up", "down" o "delete"
ACCION="${MODO_PLACA}"

case "$ACCION" in
    setup)
        echo "Verificando configuraciones previas..."
        if nmcli connection show | grep -qw "$PERFIL"; then
            echo "El perfil '$PERFIL' ya existe en tu sistema."
            echo "Si deseas reconfigurarlo, elimínalo primero con: MODO_PLACA=delete ./gestion_placa.sh"
            exit 1
        fi
        
        echo "Creando el perfil de red estático ($IP_PC) en $INTERFAZ..."
        nmcli connection add type ethernet con-name "$PERFIL" ifname "$INTERFAZ" ipv4.method manual ipv4.addresses "$IP_PC"
        
        if [ $? -eq 0 ]; then
            echo "Desactivando la autoconexión..."
            nmcli connection modify "$PERFIL" connection.autoconnect no
            echo "¡Perfil '$PERFIL' configurado exitosamente! Ya puedes usar 'up' y 'down'."
        else
            echo "Error: No se pudo crear el perfil de red."
            exit 1
        fi
        ;;
        
    up)
        echo "Levantando el perfil de red: $PERFIL..."
        nmcli connection up "$PERFIL"
        
        if [ $? -eq 0 ]; then
            echo "Conexión física establecida. Forzando ruta directa..."
            sudo ip route replace "$IP_PLACA" dev "$INTERFAZ"
            echo "¡Listo! El tráfico hacia $IP_PLACA ahora viaja exclusivamente por cable."
        else
            echo "Error: No se pudo levantar el perfil. ¿Está conectado el cable?"
            exit 1
        fi
        ;;
        
    down)
        echo "Apagando el perfil de red: $PERFIL..."
        nmcli connection down "$PERFIL"
        
        if [ $? -eq 0 ]; then
            sudo ip route del "$IP_PLACA" dev "$INTERFAZ" 2>/dev/null
            echo "¡Limpieza completada! El puerto Ethernet está libre para otras conexiones."
        else
            echo "Error: No se pudo apagar el perfil (probablemente ya estaba inactivo)."
            exit 1
        fi
        ;;
        
    delete)
        echo "Eliminando el perfil de red: $PERFIL..."
        if nmcli connection show | grep -qw "$PERFIL"; then
            # Primero nos aseguramos de apagarlo y limpiar rutas si estuviera activo
            nmcli connection down "$PERFIL" 2>/dev/null
            sudo ip route del "$IP_PLACA" dev "$INTERFAZ" 2>/dev/null
            
            # Ahora lo eliminamos de NetworkManager
            nmcli connection delete "$PERFIL"
            
            if [ $? -eq 0 ]; then
                echo "¡Perfil '$PERFIL' eliminado correctamente del sistema!"
            else
                echo "Error al intentar eliminar el perfil."
                exit 1
            fi
        else
            echo "El perfil '$PERFIL' no existe, no hay nada que eliminar."
        fi
        ;;
        
    *)
        echo "Error: Variable de entorno MODO_PLACA no definida o inválida."
        echo "Opciones válidas: setup, up, down, delete."
        echo ""
        echo "Uso correcto:"
        echo "  MODO_PLACA=setup  ./via_ethernet.sh   # Crea el perfil por primera vez"
        echo "  MODO_PLACA=up     ./via_ethernet.sh   # Conecta a la placa y enruta"
        echo "  MODO_PLACA=down   ./via_ethernet.sh   # Desconecta y limpia rutas"
        echo "  MODO_PLACA=delete ./via_ethernet.sh   # Elimina el perfil por completo"
        exit 1
        ;;
esac