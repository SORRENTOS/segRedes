#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
echo "[*] 0/5: Inicio de aprovisionamiento (modo no interactivo APT)."
echo "[*] 1/5: Actualizando repositorios y sistema..."
# Ahora ejecútalo directamente (esta parte sí corre cambios reales)
sudo apt-get update -qq && sudo apt-get upgrade -y -qq
echo "[*] 2/5: Instalando SOC (Suricata, Docker, Python3)..."

# Instala ahora
sudo apt-get install -y -qq python3-pip python3-venv suricata docker.io docker-compose curl git jq software-properties-common
echo "[*] 2b: Activando Suricata (backup y edición de /etc/suricata/suricata.yaml)..."

# Corre ahora
sudo cp /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml.bak.$(date +%F-%H%M%S)
sudo sed -i 's/enabled: no/enabled: yes/g' /etc/suricata/suricata.yaml
echo "[*] 3/5: Estructurando el entorno Fintech Sur para el usuario 'benjamin'..."

USER_HOME="/home/benjamin"
WORK_DIR="$USER_HOME/fintech_sur"

sudo -u benjamin mkdir -p $WORK_DIR/{logs,red_simulada,scripts}
sudo -u benjamin touch $WORK_DIR/logs/suricata_eve.json
#Creacion Motor Dlp
sudo -u benjamin bash -c "cat > $WORK_DIR/scripts/1_motor_dlp.py" << 'PYEOF'
import re, json
def ofuscar_datos(log_crudo):
    pass # TODO: Implementar lógica Ley 21.719
if __name__ == "__main__":
    print("Módulo DLP iniciado.")
PYEOF
# Script 2: Cliente API async
sudo -u benjamin bash -c "cat > $WORK_DIR/scripts/2_cliente_api.py" << 'PYEOF'
import aiohttp, asyncio, os
from dotenv import load_dotenv
# TODO: Conexión asíncrona a la API.
PYEOF
# Archivo de variables de entorno ejemplo
sudo -u benjamin bash -c "cat > $WORK_DIR/.env.example" << 'ENVEOF'
LLM_API_KEY=ingrese_su_llave_aqui
LLM_API_URL=https://api.groq.com/openai/v1/chat/completions
ENVEOF
# Red simulada (docker-compose v3)
sudo -u benjamin bash -c "cat > $WORK_DIR/red_simulada/docker-compose.yml" << 'YAMLEOF'
version: '3'
services:
  servidor_web_vulnerable:
    image: nginx:alpine
    ports:
      - "8080:80"
YAMLEOF


echo "[*] 4/5: Compilando Entorno Virtual Python..."

# Corre ahora
sudo -u benjamin python3 -m venv /home/benjamin/fintech_sur/.venv
sudo -u benjamin /home/benjamin/fintech_sur/.venv/bin/pip install --quiet --upgrade pip
sudo -u benjamin /home/benjamin/fintech_sur/.venv/bin/pip install --quiet requests aiohttp python-dotenv pydantic netmiko regex




echo "[*] 5/5: Aplicando Hardening y configuraciones del servicio..."

# Asegurar que benjamin sea el dueño de sus archivos
sudo chown -R benjamin:benjamin /home/benjamin/fintech_sur

# Permitir que benjamin use Docker sin ser root
sudo usermod -aG docker benjamin

# Configuración netplan para interfaz host-only enp0s8
sudo bash -c 'cat > /etc/netplan/99-hostonly.yaml' << 'NETEOF'
network:
  version: 2
  ethernets:
    enp0s8:
      dhcp4: true
NETEOF

sudo netplan apply

# Reiniciar y habilitar servicios
sudo systemctl restart suricata
sudo systemctl enable docker
sudo systemctl start docker
#! VERIFICACION DE SERVICIOS
# Docker en ejecución
systemctl is-active docker

# Suricata en ejecución
systemctl status suricata --no-pager -l | sed -n '1,15p'

# Interfaz de red host-only (debe aparecer enp0s8 con IP)
ip -4 addr show enp0s8 || ip a