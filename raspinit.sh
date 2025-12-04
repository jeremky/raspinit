#!/bin/bash -e

dir=$(dirname "$(realpath "$0")")

# Messages en couleur
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
else
  apt update
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
  apt purge -y wpasupplicant
  message "Wifi désactivé"
fi

# Bluetooth
if [[ $bluetooth = "off" ]]; then
  warning "Désactivation du Bluetooth..."
  echo "dtoverlay=disable-bt" | tee -a /boot/firmware/config.txt
  systemctl disable hciuart
  apt purge -y bluez
  message "Bluetooth désactivé"
fi

# Modem
if [[ $modem = "off" ]]; then
  warning "Suppression de ModemManager..."
  sudo apt purge -y modemmanager
  message "ModemManager supprimé"

# ddclient
if [[ $ddclient = "on" ]]; then
  warning "Installation de ddclient..."
  apt install -y ddclient
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
  if [[ -f /usr/sbin/ufw ]]; then
    ufw allow 67,68/udp
    ufw allow 53
    ufw allow 3000/tcp
  fi
  message "Installation de Adguard Home effectuée"
  echo
fi

# Shairport Sync
if [[ $shairport = "on" ]]; then
  warning "Installation de shairport sync"
  apt install -y shairport-sync
  if [[ -f /usr/sbin/ufw ]]; then
    sudo ufw allow 319:320/udp
    ufw allow 3689/tcp
    ufw allow 5353
    ufw allow 5000/tcp
    ufw allow 7000/tcp
    ufw allow 6000:6009/udp
    ufw allow 32768:60999/udp
    ufw allow 32768:60999/tcp
  fi
  if [[ -f /$dir/cfg/shairport-sync.conf ]]; then
    cp $dir/cfg/shairport.conf /etc/shairport-sync.conf
    systemctl restart shairport-sync
  fi
  message "Installation de shirport sync effectuée"
  echo
fi

# Log2Ram
if [[ $log2ram = "on" ]]; then
  warning "Installation de Log2ram..."
  apt install -y log2ram rsync
  [[ -f $dir/cfg/log2ram.cfg ]] && cp $dir/cfg/log2ram.cfg /etc/log2ram.conf
  message "Installation de log2ram effectuée"
  read -p "Redémarrage nécessaire. Confirmer (o/n) : " reponse
  case $reponse in
    o)
      reboot
      ;;
    *)
      warning "Redémarrez avant toute autre installation !"
      echo
      ;;
  esac
fi
