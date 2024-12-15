#!/bin/dash

## Variables
dir=$(dirname "$0")

## User
if [ "$USER" != "root" ] ; then
  echo "Droits root nécessaires"
  exit 0
fi

## Installation du dépot
if [ ! -f /usr/local/bin/log2ram ] ; then
  echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bookworm main" | tee /etc/apt/sources.list.d/azlux.list
  wget -O /usr/share/keyrings/azlux-archive-keyring.gpg  https://azlux.fr/repo.gpg
  apt update
  apt -y install rsync log2ram
  cp $dir/log2ram.cfg /etc/log2ram.conf
  ## Redemarrage
  read -p "Redémarrage nécessaire. Confirmer (o/n): " reponse
  case $reponse in
    o)
      reboot
      ;;
    *)
      echo "Redemarrez avant toute autre installation !"
      exit 0
      ;;
  esac
else
  echo "log2ram est déjà installé"
fi
