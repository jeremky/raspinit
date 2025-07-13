#!/bin/bash -e

dir=$(dirname "$(realpath "$0")")

# Messages colorisés
error()    { echo -e "\033[0;31m====> $*\033[0m" ;}
message()  { echo -e "\033[0;32m====> $*\033[0m" ;}
warning()  { echo ; echo -e "\033[0;33m====> $*\033[0m" ;}

# Vérification de l'OS
if [[ ! -f /usr/bin/raspi-config ]]; then
  error "Appareil Incompatible !"
  exit 1
fi

# Config
cfg=$dir/raspinit.cfg
if [[ -f $cfg ]]; then
  . $cfg
else
  error "Fichier $cfg introuvable"
  exit 1
fi

# User
if [[ $USER != root ]]; then
  error "Droits root nécessaires"
  exit 1
fi

# Alias
if [[ $tempalias = "on" ]]; then
  echo >> /etc/profile
  echo -e "# Temperature\nalias temp='sudo vcgencmd measure_temp'" >> /etc/profile
fi

# Swap
if [[ $swap = "off" ]]; then
  warning "Désactivation du Swap..."
  swapoff --all
  apt -y remove dphys-swapfile
  apt -y autoremove
  rm -f /var/swap
  message "Swap désactivé"
fi

# Wifi
if [[ $wifi = "off" ]]; then
  warning "Désactivation du Wifi..."
  echo "dtoverlay=disable-wifi" | tee -a /boot/firmware/config.txt
  systemctl disable wpa_supplicant
  message "Wifi désactivé"
fi

# Bluetooth
if [[ $bluetooth = "off" ]]; then
  warning "Désactivation du Bluetooth..."
  echo "dtoverlay=disable-bt" | tee -a /boot/firmware/config.txt
  systemctl disable hciuart
  message "Bluetooth désactivé"
fi

## ddclient
if [[ $ddclient = "on" ]]; then
  warning "Installation de ddclient..."
  apt update && apt install -y ddclient
  message "Installation de ddclient effectuée"
  echo
  if [[ -f $dir/cfg/ddclient.cfg ]]; then
    cp $dir/cfg/ddclient.cfg /etc/ddclient.conf
    systemctl restart ddclient
  else
    error "Fichier $dir/cfg/ddclient.cfg non présent"
  fi
fi

# Adguard Home
if [[ $adguard = "on" ]]; then
  warning "Installation de Adguard Home..."
  curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v
  message "Installation de Adguard Home effectuée"
  echo
fi

# Log2Ram
if [[ $log2ram = "on" ]]; then
  apt update && apt install -y wget rsync
  echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bookworm main" | tee /etc/apt/sources.list.d/azlux.list
  wget -O /usr/share/keyrings/azlux-archive-keyring.gpg https://azlux.fr/repo.gpg
  apt update && apt install -y log2ram
  [[ -f $dir/cfg/log2ram.cfg ]] && cp $dir/cfg/log2ram.cfg /etc/log2ram.conf
  read -p "Redémarrage nécessaire. Confirmer (o/n): " reponse
  case $reponse in
    o)
      reboot
      ;;
    *)
      warning "Redémarrez avant toute autre installation !"
      ;;
  esac
fi
