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