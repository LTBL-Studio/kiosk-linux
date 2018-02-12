#!/bin/bash

# Fichier de log des commandes mises en sourdine
LOGFILE="./setup.log"
# Paquet du gestionnaire de fenêtres
WINDOWSMANAGER="lwm"
# Si on doit installer les drivers audio
AUDIO="yes"
# Utilisateur du kiosk
KUSER="kiosk"
# Packages supplémentaires à installer
EXTRAPACKAGES=""
# Commande de démarrage
COMMAND="xterm"
# Desactivation du grub
DISABLEGRUB="yes"
# Cacher le curseur de la souris
HIDECURSOR="yes"
# Temps d'attente du réseau
NETWORKWAIT="5sec"
# redémarrer apres l'installation
REBOOT="yes"
# Système de mise à jour
UPDATE="yes"