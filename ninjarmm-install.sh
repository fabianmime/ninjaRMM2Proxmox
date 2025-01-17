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

# Farben für Statusmeldungen
RD=$(echo "\033[01;31m")
YW=$(echo "\033[33m")
GN=$(echo "\033[1;92m")
CL=$(echo "\033[m")
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"

# Fehlerbehandlung
set -euo pipefail
shopt -s inherit_errexit nullglob

# Funktion für Informationsmeldungen
msg_info() {
  local msg="$1"
  echo -ne " ${HOLD} ${YW}${msg}..."
}

# Funktion für Erfolgsmeldungen
msg_ok() {
  local msg="$1"
  echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

# Funktion für Fehlermeldungen
msg_error() {
  local msg="$1"
  echo -e "${BFR} ${CROSS} ${RD}${msg}${CL}"
}

# Hauptfunktion
start_installation() {
  header_info

  # Abfrage des Installationslinks
  AGENT_URL=$(whiptail --inputbox "Bitte geben Sie den Installationslink für den NinjaOne-Agenten ein:" 10 60 3>&1 1>&2 2>&3)

  # Überprüfen, ob eine URL eingegeben wurde
  if [[ -z "$AGENT_URL" ]]; then
    msg_error "Kein Installationslink eingegeben. Installation abgebrochen."
    exit 1
  fi

  # Temporären Pfad für den Download festlegen
  AGENT_DEB="/tmp/ninjaone-agent.deb"

  # Herunterladen des NinjaOne-Agenten
  msg_info "Lade NinjaOne-Agent herunter"
  if ! curl -o "$AGENT_DEB" "$AGENT_URL" &>/dev/null; then
    msg_error "Fehler beim Herunterladen des NinjaOne-Agenten."
    exit 1
  fi
  msg_ok "Download abgeschlossen"

  # Installation des NinjaOne-Agenten
  msg_info "Installiere NinjaOne-Agent"
  if ! dpkg -i "$AGENT_DEB" &>/dev/null; then
    msg_error "Fehler bei der Installation. Versuche, Abhängigkeiten zu beheben."
    if ! apt-get install -f -y &>/dev/null; then
      msg_error "Fehler beim Installieren der Abhängigkeiten."
      exit 1
    fi
  fi
  msg_ok "Installation abgeschlossen"

  # Entfernen der heruntergeladenen Datei
  rm "$AGENT_DEB"
}

# Skript starten
header_info
echo -e "\nDieses Skript installiert den NinjaOne-Agenten auf dem Proxmox-Server.\n"
while true; do
  read -p "Fortfahren? (j/n): " yn
  case $yn in
    [Jj]* ) start_installation; break;;
    [Nn]* ) clear; exit;;
    * ) echo "Antworten mit j (ja) oder n (nein).";;
  esac
done
