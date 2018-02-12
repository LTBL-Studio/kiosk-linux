#!/bin/bash

# Arrète le script s'il y a une érreur de commande
set -e

# Un petit message d'aide dans le cas ou on tape --help
if [[ $1 == "--help" ]]; then
	echo "Usage : ./setup-kiosk.sh [configScript]"
	exit 0
fi

# On vérifie que l'utilisateur est root
if [[ ! $UID -eq 0 ]]; then
	echo "Only root can execute this script"
	exit 1
fi

echo "  _    _                _  ___        _   "
echo " | |  (_)_ _ _  ___ __ | |/ (_)___ __| |__"
echo " | |__| | ' \ || \ \ / | ' <| / _ (_-< / /"
echo " |____|_|_||_\_,_/_\_\ |_|\_\_\___/__/_\_\\"
echo "                                          "
echo ""

# On charge la configuration par défaut
source defaults.sh

# Si on ne mentionne pas la configuration, on demande les informations à l'utilisateur
if [[ $1 == "" ]]; then
	source config-interactive.sh
else
	# On vérifie que le fichier existe
	if [[! -f $1]]; then
		echo "Config script not found"
		exit 1
	fi
	source $1
fi

echo ""
echo "Démarrage de l'installation"
echo ""

echo "Installation du serveur X"
apt-get install xorg xserver-xorg-legacy -y >> $LOGFILE
echo "allowed_users=anybody" > /etc/X11/Xwrapper.config

echo "Installation du gestionnaire de fenêtres"
apt-get install "$WINDOWSMANAGER" -y >> $LOGFILE

if [[ $AUDIO == "yes" ]]; then
	echo "Installation des composants audio"
	apt-get install -y alsa-base alsa-utils alsa-tools pulseaudio >> $LOGFILE
fi

if [[ $EXTRAPACKAGES != "" ]]; then
	echo "Installation des packages supplémentaires"
	apt-get install $EXTRAPACKAGES -y >> $LOGFILE
fi

if [[ $HIDECURSOR == "yes" ]]; then
	echo "Installation de unclutter"
	apt-get install unclutter -y >> $LOGFILE
fi

echo "Creation et configuration de l'utilisateur d'affichage"
useradd -m $KUSER -c "Le compte en charge d'afficher l'application de kiosk"
usermod -aG tty $KUSER
if [[ $AUDIO == "yes" ]]; then
	usermod -aG audio $KUSER
fi


mkdir -p /etc/systemd/system/getty@tty1.service.d
echo "[Service]
ExecStart=
ExecStart=-/sbin/agetty --noclear -a $KUSER %I $TERM" > /etc/systemd/system/getty@tty1.service.d/override.conf

echo "Creation des scripts de démarrage"
cp ./kuser-bash-profile.sh /home/$KUSER/.bash_profile

echo "#!/bin/bash
# On annule l'économie d'énergie et la mise en veille de l'ecran
xset -dpms
xset s off" > /home/$KUSER/kiosk_start.sh

if [[ $AUDIO == "yes" ]]; then
	echo "# On active les drivers audio
start-pulseaudio-x11" >> /home/$KUSER/kiosk_start.sh
fi


if [[ $HIDECURSOR == "yes" ]]; then
	echo "# On active les drivers audio
unclutter -idle \"0.01\" -root" >> /home/$KUSER/kiosk_start.sh
fi

echo "# On démarre en arrière plan le gestionnaire de fenêtres
$WINDOWSMANAGER &
# On attend que le gestionnaire soit ouvert
sleep 1
# On démarre l'application de kiosk
$COMMAND" >> /home/$KUSER/kiosk_start.sh

chmod +xr /home/$KUSER/kiosk_start.sh /home/$KUSER/.bash_profile

if [[ $DISABLEGRUB == "yes" ]]; then
	echo "Desactivation du GRUB"
	cp kuser-files/disabled-grub-config.conf /etc/default/grub
	update-grub >> $LOGFILE
fi

echo "Définition du temps d'attente réseau"
set -i -e "s/TimeoutStartSec=[^\n]+/TimeoutStartSec=$NETWORKWAIT/g" "/etc/systemd/system/network-online.targets.wants/networking.service"

if [[ $UPDATE == "yes" ]]; then
	echo "Installation du système de mise à jour"
	cp kuser-files/make-update.sh /home/$KUSER
	chmod +xr /home/$KUSER/make-update.sh
	mkdir /home/$KUSER/update-actions
fi

echo ""
echo "Installation terminée"
if [[ $REBOOT == "yes" ]]; then
	echo "Redémarrage"
	reboot
fi