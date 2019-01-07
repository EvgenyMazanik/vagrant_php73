#!/usr/bin/env bash

echo "-- Update packages --"
sudo apt-get dist-upgrade
sudo apt-get update
sudo apt-get upgrade

echo "-- apache2-reload.sh --"
sudo sh /desk/apache2-reload.sh
