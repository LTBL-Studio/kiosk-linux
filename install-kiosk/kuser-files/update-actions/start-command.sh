#!/bin/bash
echo "Mise à jour de la commande de démarrage"
CONTENT=$(head -n -1 kiosk_start.sh)
printf "${CONTENT}\n$@" > kiosk_start.sh