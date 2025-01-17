#!/usr/bin/env bash

# Copyright (c) 2025 Computer Trend
# Author: Fabian MiMe
# License: MIT
# https://github.com/fabianmime/ninjaRMM2Proxmox/blob/main/LICENSE

header_info() {
  clear
  cat <<"EOF"
   _____                            _              _______                 _ 
  / ____|                          | |            |__   __|               | |
 | |     ___  _ __ ___  _ __  _   _| |_ ___ _ __     | |_ __ ___ _ __   __| |
 | |    / _ \| '_ ` _ \| '_ \| | | | __/ _ \ '__|    | | '__/ _ \ '_ \ / _` |
 | |___| (_) | | | | | | |_) | |_| | ||  __/ |       | | | |  __/ | | | (_| |
  \_____\___/|_| |_| |_| .__/ \__,_|\__\___|_|       |_|_|  \___|_| |_|\__,_|
                       | |                                                   
                       |_|                                                   
EOF
}

RD=$(echo -e "\033[01;31m")
YW=$(echo -e "\033[33m")
GN=$(echo -e "\033[1;92m")
CL=$(echo -e "\033[m")
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"

msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YW}${msg}..."
}

msg_ok() {
  local msg="$1"
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

msg_error() {
  local msg="$1"
  echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}

header_info

# Überprüfen, ob das Skript mit Root-Rechten ausgeführt wird
if [ "$EUID" -ne 0 ]; then
  msg_error "Bitte führen Sie dieses Skript mit Root-Rechten aus."
  exit 1
fi

# Überprüfen, ob der NinjaRMMAgent installiert ist
if dpkg-query -W -f='${Status}' NinjaRMMAgent 2>/dev/null | grep -q "installiert"; then
  # Bestätigung einholen
  read -p "Möchten Sie den NinjaRMMAgent wirklich deinstallieren? (j/n): " choice
  case "$choice" in 
    j|J )
      msg_info "Deinstalliere NinjaRMMAgent..."
      # Dienst stoppen
      systemctl stop ninjarmm-agent.service
      # Dienst deaktivieren
      systemctl disable ninjarmm-agent.service
      # Dateien und Verzeichnisse entfernen
      rm -rf /opt/NinjaRMMAgent
      rm -f /etc/systemd/system/ninjarmm-agent.service
      rm -f /etc/systemd/system/multi-user.target.wants/ninjarmm-agent.service
      rm -f /lib/systemd/system/ninjarmm-agent.service
      rm -rf /var/lib/dpkg/info/NinjaRMMAgent.*
      # Systemd neu laden
      systemctl daemon-reload
      systemctl reset-failed
      msg_ok "NinjaRMMAgent wurde erfolgreich deinstalliert."
      ;;
    n|N )
      msg_info "Deinstallation abgebrochen."
      ;;
    * )
      msg_error "Ungültige Eingabe. Bitte 'j' für Ja oder 'n' für Nein eingeben."
      ;;
  esac
else
  msg_error "NinjaRMMAgent ist nicht auf diesem System installiert."
fi
