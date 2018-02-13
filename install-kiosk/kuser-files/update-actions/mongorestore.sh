#!/bin/bash
echo "Restauration de la base de données mongoDB"
mongorestore "${UPDATEFOLDER}/$1"