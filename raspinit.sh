#!/bin/bash -e

dir=$(dirname "$0")

# Vérification de l'OS
if [[ ! -f /usr/bin/raspi-config ]]; then
  echo "Incompatible !"
  exit 0
fi

# Config
cfg=$dir/raspinit.cfg
if [[ -f $cfg ]]; then
  . $cfg
else
  echo "Fichier $cfg introuvable"
  exit 0
fi

# User
if [[ $USER != root ]]; then
  echo "Droits root nécessaires"
  exit 0
fi

# Alias
echo "" >> /etc/profile
echo -e "# Temperature\nalias temp='sudo vcgencmd measure_temp'" >> /etc/profile

# Swap
if [[ $swap = "off" ]]; then
  swapoff --all
  apt -y remove dphys-swapfile
  apt -y autoremove
  rm -f /var/swap
fi

# Wifi
if [[ $wifi = "off" ]]; then
  echo "dtoverlay=disable-wifi" | tee -a /boot/firmware/config.txt
  systemctl disable wpa_supplicant
  echo "Wifi désactivé"
fi

# Bluetooth
if [[ $bluetooth = "off" ]]; then
  echo "dtoverlay=disable-bt" | tee -a /boot/firmware/config.txt
  systemctl disable hciuart
  echo "Bluetooth désactivé"
fi

# Log2Ram
if [[ $log2ram = "on" ]]; then
  apt update && apt install -y wget rsync
  echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bookworm main" | tee /etc/apt/sources.list.d/azlux.list
  wget -O /usr/share/keyrings/azlux-archive-keyring.gpg https://azlux.fr/repo.gpg
  apt update && apt install -y log2ram
  cp $dir/log2ram.cfg /etc/log2ram.conf
  read -p "Redémarrage nécessaire. Confirmer (o/n): " reponse
  case $reponse in
    o)
      reboot
      ;;
    *)
      echo "Redémarrez avant toute autre installation !"
      ;;
  esac
fi
