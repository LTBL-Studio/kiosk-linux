#!/bin/bash
echo "Mise à jour de la commande de démarrage"
CONTENT=$(head -n -1 kiosk_start.sh)
printf "${CONTENT}" > kiosk_start.sh
echo "$@" >> kiosk_start.sh