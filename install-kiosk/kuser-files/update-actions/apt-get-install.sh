#!/bin/bash
echo "Installation de packages supplémentaires"
echo "$@"
apt-get install -y $@