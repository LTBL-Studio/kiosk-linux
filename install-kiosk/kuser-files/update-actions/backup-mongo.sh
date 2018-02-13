#!/bin/bash
TIMESTAMP=$(date +%s)
set -e
echo "Creation d'un point de restauration de la base de données mongoDB"
mongodump --out="/tmp/mongodump"
tar czf "mongo-${TIMESTAMP}.tar.gz" "/tmp/mongodump"