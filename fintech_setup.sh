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