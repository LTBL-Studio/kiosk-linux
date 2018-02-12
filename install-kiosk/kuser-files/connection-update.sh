#!/bin/bash

cd $(dirname $0)
set -e

if [[ "$1" == "" ]]; then
	echo "Action required"
	exit 1
elif [[ "$2" == "" ]]; then
	echo "Devname required"
	exit 1
fi

ACTION="$1"
DEVNAME="$2"
MOUNTROOT="/media/update"
MOUNTFOLDER="${MOUNTROOT}/$DEVNAME"

if [[ "$ACTION" == "add" ]]; then

	echo "Mounting $DEVNAME in $MOUNTROOT"
	mkdir "$MOUNTFOLDER" -p
	mount "/dev/$DEVNAME" "$MOUNTFOLDER"	

	echo "Looking for update file"
	if [[ -f "$MOUNTFOLDER/update.conf" ]]; then
		echo "Update found, applying update..."
		./make-update.sh "$MOUNTFOLDER"
	else
		echo "No update found"
	fi

fi

echo "Unmounting $DEVNAME in $MOUNTROOT"
umount "$MOUNTFOLDER"
rmdir "$MOUNTFOLDER"