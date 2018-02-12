#!/bin/bash

TIMESTAMP=$(date +%s)
export TIMESTAMP

if [[ $1 == "" ]]; then
	echo "Source update folder is required"
	exit 1
fi

if [[ $1 == "--help" ]]; then
	echo "Usage : ./make-update.sh [sourceUpdateFolder]"
	exit 0
fi

if [[ ! -d $1 ]]; then
	echo "Source update folder not found"
	exit 1
fi

UPDATEFILE="$1/update.conf"
VERSIONFILE="$1/update.version"

if [[ ! -f $UPDATEFILE ]]; then
	echo "No update file in source update folder"
	exit 1
fi

if [[ ! $UID -eq 0 ]]; then
	echo "Only root can execute this script"
	exit 1
fi

# Creation du fichier bloquant l'interface
touch ./update.lock
LOGFILE="update.lock"
UPDATEFOLDER=$1
export UPDATEFOLDER
# Arret du serveur X pour le redémarrage de l'interface
killall xinit

if [[ ! -f $VERSIONFILE ]]; then
	echo "Aucun fichier de version dans le disque de mise à jour." >> $LOGFILE
else
	UPDATEVERSION=$(cat "$VERSIONFILE")
	if [[ ! -f "./app.version" ]]; then
		echo "Aucun fichier de version dans les dossiers de l'application" >> $LOGFILE
	else
		CURRENTVERSION=$(cat "./app.version")
		if [[ "$CURRENTVERSION" == "$UPDATEVERSION" ]]; then
			echo "La version actuelle est la même que la version du disque." >> $LOGFILE
			echo "Mise à jour inutile" >> $LOGFILE
			sleep 10
			cp $LOGFILE "$1/update-$TIMESTAMP.log"
			rm $LOGFILE
			exit 1
		fi
	fi
	echo "$UPDATEVERSION" > ./app.version
	echo "Mise à jour vers la version $UPDATEVERSION" >> $LOGFILE
fi

echo "Démarrage de la mise à jour" >> $LOGFILE

set -e

UPDATEFILECONTENT=$(cat $UPDATEFILE)

IFS=$'\n'
for line in $UPDATEFILECONTENT; do
	action=$(echo $line |sed "s/ .*$//")
	args=$(echo $line |sed "s/^[^ ]* //")
	if [[ ! -f "./update-actions/${action}.sh" ]]; then
		echo "L'action $action est inconnue" >> $LOGFILE
	else
		/bin/bash -c "./update-actions/${action}.sh $args" >> $LOGFILE
	fi
done

echo "Fin de la mise à jour" >> $LOGFILE
echo "Redémarrage dans 10 secondes" >> $LOGFILE
sleep 10
cp $LOGFILE "$1/update-$TIMESTAMP.log"
rm $LOGFILE