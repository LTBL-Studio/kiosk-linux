#!/bin/bash
TIMESTAMP=$(date +%s)
APPFOLDER="biopedia"
echo "Creation d'un point de restauration de l'application"
if [[ -d "./$APPFOLDER" ]]; then
	tar czf "${APPFOLDER}-${TIMESTAMP}.tar.gz" "./$APPFOLDER"
fi