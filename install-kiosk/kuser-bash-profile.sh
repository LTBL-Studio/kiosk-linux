#!/bin/bash

clear

if [[ -f ./update.lock ]]; then
		
	echo "  _   _ ___ ___   _ _____ ___  "
	echo " | | | | _ \   \ /_\_   _| __| "
	echo " | |_| |  _/ |) / _ \| | | _|  "
	echo "  \___/|_| |___/_/ \_\_| |___| "
	echo "                               "
	echo " Une mise à jour est en cours. "
	echo " Le système redémarrera dès la "
	echo "     mise à jour terminée      "
	echo ""
	echo " ----------------------------- "
	echo ""

	tail -f ./update.lock &

	TAILPID=$!

	while [[ -f ./update.lock ]]; do
		sleep 5
	done

	kill $TAILPID

	exit 1
fi

# On démarre simplement un serveur X en session standard avec le script "kiosk_start.sh"
# la commande exec permet de remplacer le processus actuel par le serveur x 
# et ainsi éviter le retour au bash si l'application plante
exec startx /etc/X11/Xsession ./kiosk_start.sh