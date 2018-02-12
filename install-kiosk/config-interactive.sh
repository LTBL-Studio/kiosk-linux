#!/bin/bash

read -e -p "Gestionnaire de fenêtres : " -i "$WINDOWSMANAGER" WINDOWSMANAGER
read -e -p "Installer les composants audio : " -i "$AUDIO" AUDIO
read -e -p "Installer le système de Mise à jour : " -i "$UPDATE" UPDATE
read -e -p "Désactiver le GRUB : " -i "$DISABLEGRUB" DISABLEGRUB
read -e -p "cacher le curseur : " -i "$HIDECURSOR" HIDECURSOR
read -e -p "Temps d'attente du réseau : " -i "$NETWORKWAIT" NETWORKWAIT
read -e -p "Packages supplémentaires : " -i "$EXTRAPACKAGES" EXTRAPACKAGES
read -e -p "Commande de démarrage : " -i "$COMMAND" COMMAND
read -e -p "Redémarrer apres l'installation : " -i "$REBOOT" REBOOT