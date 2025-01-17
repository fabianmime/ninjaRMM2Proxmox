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

# Versuchen, den tatsächlichen Paketnamen des NinjaRMMAgent zu ermitteln
PACKAGE_NAME=$(dpkg-query -W -f='${binary:Package}\n' | grep -i 'ninjarmm')

if [ -n "$PACKAGE_NAME" ]; then
  # Bestätigung einholen
  read -p "Möchten Sie den $PACKAGE_NAME wirklich deinstallieren? (j/n): " choice
  case "$choice" in 
    j|J )
      msg_info "Deinstalliere $PACKAGE_NAME..."
      if dpkg --purge "$PACKAGE_NAME" &>/dev/null; then
        msg_ok "$PACKAGE_NAME wurde erfolgreich deinstalliert."
      else
        msg_error "Fehler bei der Deinstallation von $PACKAGE_NAME."
      fi
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
