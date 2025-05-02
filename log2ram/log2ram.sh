#!/bin/bash -e

# User
if [[ $USER != root ]]; then
  echo "Droits root nécessaires"
  exit 0
fi

if [[ ! -f /usr/local/bin/log2ram ]]; then
  apt update && apt install -y wget
  echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bookworm main" | tee /etc/apt/sources.list.d/azlux.list
  wget -O /usr/share/keyrings/azlux-archive-keyring.gpg https://azlux.fr/repo.gpg
  apt update
  apt -y install rsync log2ram
  cp $(dirname "$0")/log2ram.cfg /etc/log2ram.conf
  read -p "Redémarrage nécessaire. Confirmer (o/n): " reponse
  case $reponse in
    o)
      reboot
      ;;
    *)
      echo "Redemarrez avant toute autre installation !"
      ;;
  esac
else
  echo "log2ram est déjà installé"
fi
