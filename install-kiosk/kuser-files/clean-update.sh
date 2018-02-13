#!/bin/bash
cd /home/kiosk
echo "Nettoyage des précédentes mise à jour"
if [ -f ./update.lock ]; then
	echo "Une ancienne Mise à jour etait en cours sur cette machine."
	echo "L'application sera peut être instable."
	rm ./update.lock
	echo "cleaned" >> ./app.version
fi