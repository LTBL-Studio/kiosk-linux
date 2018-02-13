#!/bin/bash
TIMESTAMP=$(date +%s)
set -e
echo "Creation d'un point de restauration de la base de données mongoDB"
mongodump --gzip --archive="./mongo-${TIMESTAMP}.tar.gz"