#!/bin/bash

# Messages en couleur
error() { echo -e "\033[0;31m====> $*\033[0m"; }
message() { echo -e "\033[0;32m====> $*\033[0m"; }
warning() { echo -e "\033[0;33m====> $*\033[0m"; }

# Vérification de l'OS
if [[ ! -f /usr/bin/raspi-config ]]; then
  error "Appareil Incompatible !"
  exit 1
fi

# Config
dir=$(dirname "$0")
cfg="$dir/raspinit.cfg"
if [[ ! -f "$cfg" ]]; then
  error "Fichier $cfg introuvable"
  exit 1
fi

# User
if [[ "$EUID" -ne 0 ]]; then
  error "Droits root nécessaires"
  exit 1
fi

# Fonctions
enable_tempalias() {
  warning "Création de l'alias temp..."
  echo -e "\n# Temperature\nalias temp='sudo /usr/bin/vcgencmd measure_temp'" >>/etc/profile
  echo "%sudo ALL=(ALL) NOPASSWD: /usr/bin/vcgencmd measure_temp" >/etc/sudoers.d/010_temp
  chmod 440 /etc/sudoers.d/010_temp
  message "Alias temp ajouté à /etc/profile"
}

disable_swap() {
  warning "Désactivation du Swap..."
  swapoff --all
  apt -y remove dphys-swapfile
  apt -y autoremove
  rm -f /var/swap
  message "Swap désactivé"
}

disable_wifi() {
  warning "Désactivation du Wifi..."
  echo "dtoverlay=disable-wifi" | tee -a /boot/firmware/config.txt
  systemctl disable wpa_supplicant
  apt purge -y wpasupplicant
  message "Wifi désactivé"
}

disable_bluetooth() {
  warning "Désactivation du Bluetooth..."
  echo "dtoverlay=disable-bt" | tee -a /boot/firmware/config.txt
  systemctl disable hciuart
  apt purge -y bluez
  message "Bluetooth désactivé"
}

disable_modem() {
  warning "Suppression de ModemManager..."
  apt purge -y modemmanager
  message "ModemManager supprimé"
}

install_ddclient() {
  warning "Installation de ddclient..."
  if [[ ! -f "$dir/config/ddclient.conf" ]]; then
    error "Fichier $dir/config/ddclient.conf non présent"
  else
    apt -y install ddclient
    cp "$dir/config/ddclient.conf" /etc/ddclient.conf
    systemctl restart ddclient
    message "Installation de ddclient effectuée"
  fi
}

install_adguard() {
  warning "Installation de Adguard Home..."
  if curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v; then
    message "Installation de Adguard Home effectuée"
  else
    error " Echec de l'installation de Adguard Home"
  fi
}

install_shairport() {
  warning "Installation de shairport sync"
  if [[ ! -f "$dir/config/shairport.conf" ]]; then
    error "Fichier $dir/config/shairport.conf non présent"
  else
    apt -y install shairport-sync
    cp "$dir/config/shairport.conf" /etc/shairport-sync.conf
    echo -e "# Shairport\n0 6 * * * root /usr/bin/systemctl restart shairport-sync.service >/dev/null 2>&1" >/etc/cron.d/shairport
    systemctl restart shairport-sync
    message "Installation de shairport sync effectuée"
  fi
}

install_log2ram() {
  warning "Installation de Log2ram..."
  if [[ ! -f "$dir/config/log2ram.conf" ]]; then
    error "Fichier $dir/config/log2ram.conf non présent"
  else
    apt -y install rsync log2ram
    cp "$dir/config/log2ram.conf" /etc/log2ram.conf
    message "Installation de log2ram effectuée"
    read -rp "Redémarrage nécessaire. Confirmer (o/n) : " reponse
    case $reponse in
      o)
        reboot
        ;;
      *)
        warning "Redémarrez avant toute autre installation !"
        ;;
    esac
  fi
}

# Exécution des fonctions
if [[ -n "$1" ]]; then
  if ! declare -f "$1" >/dev/null; then
    error "Aucune fonction ne correspond au paramètre $1"
    exit 1
  fi
  "$1"
else
  apt update
  while read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    if ! declare -f "$line" >/dev/null; then
      error "Aucune fonction ne correspond au paramètre $line"
      exit 1
    fi
    "$line"
  done <"$cfg"
fi
