#!/bin/bash

# Farben für Ausgaben definieren
RED=$(echo -e "\033[01;31m")
YELLOW=$(echo -e "\033[33m")
GREEN=$(echo -e "\033[1;92m")
CLEAR=$(echo -e "\033[m")

# Funktion für Informationsmeldungen
msg_info() {
  local msg="$1"
  echo -e " ${YELLOW}${msg}...${CLEAR}"
}

# Funktion für Erfolgsmeldungen
msg_ok() {
  local msg="$1"
  echo -e " ${GREEN}✓ ${msg}${CLEAR}"
}

# Funktion für Fehlermeldungen
msg_error() {
  local msg="$1"
  echo -e " ${RED}✗ ${msg}${CLEAR}"
}

# Installationslink abfragen
read -p "Bitte geben Sie den Installationslink für den NinjaOne-Agenten ein: " AGENT_URL

# Überprüfen, ob die URL nicht leer ist
if [[ -z "$AGENT_URL" ]]; then
  msg_error "Keine URL eingegeben. Installation abgebrochen."
  exit 1
fi

# Temporären Pfad für den Download festlegen
AGENT_DEB="/tmp/ninjaone-agent.deb"

# Herunterladen des NinjaOne-Agenten
msg_info "Lade NinjaOne-Agent herunter"
curl -o "$AGENT_DEB" "$AGENT_URL"

# Überprüfen, ob der Download erfolgreich war
if [ $? -ne 0 ]; then
  msg_error "Fehler beim Herunterladen des NinjaOne-Agenten."
  exit 1
fi

# Installation des NinjaOne-Agenten
msg_info "Installiere NinjaOne-Agent"
dpkg -i "$AGENT_DEB"

# Überprüfen auf fehlende Abhängigkeiten und diese installieren
if [ $? -ne 0 ]; then
  msg_info "Überprüfe auf fehlende Abhängigkeiten"
  apt-get install -f -y
fi

# Bereinigung
msg_info "Entferne heruntergeladene Datei"
rm "$AGENT_DEB"

msg_ok "Installation abgeschlossen."
