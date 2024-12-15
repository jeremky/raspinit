#!/bin/dash
set -e

## Lecture de la config
dir=$(dirname "$0")
cfg="$dir/$(basename -s .sh $0).cfg"

## Vérification
if [ ! -f /usr/bin/raspi-config ] ; then
  echo "Incompatible !"
  exit 0
fi

## Config
if [ -f $cfg ] ; then
  . $cfg
else
  echo "Fichier $cfg introuvable"
  exit 0
fi

## User
if [ "$USER" != "root" ] ; then
  echo "Droits root nécessaires"
  exit 0
fi

## Alias
echo "" >> /etc/profile
echo "## Temperature" >> /etc/profile
echo "alias temp='sudo vcgencmd measure_temp'" >> /etc/profile

## Swap
if [ $swap = "off" ] ; then
  swapoff --all
  apt -y remove dphys-swapfile
  apt -y autoremove
  rm -f /var/swap
fi

## Wifi
if [ $wifi = "off" ] ; then
  echo "dtoverlay=disable-wifi" | tee -a /boot/firmware/config.txt
  systemctl disable wpa_supplicant
  echo "Wifi désactivé"
fi

## Bluetooth
if [ $bluetooth = "off" ] ; then
  echo "dtoverlay=disable-bt" | tee -a /boot/firmware/config.txt
  systemctl disable hciuart
  echo "Bluetooth désactivé"
fi

## Log2ram
if [ -f $dir/log2ram/log2ram.sh ] ; then
  $dir/log2ram/log2ram.sh
fi
