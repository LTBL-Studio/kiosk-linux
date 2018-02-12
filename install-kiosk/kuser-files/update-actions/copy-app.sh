#!/bin/bash
APPFOLDER="biopedia"
echo "Copie des nouveaux fichiers de l'application"
if [[ -d "./$APPFOLDER" ]]; then
	rm -rf "./$APPFOLDER"
fi
cp -rv "${UPDATEFOLDER}/$APPFOLDER" "./$APPFOLDER"