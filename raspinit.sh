#!/bin/bash

# Colored messages
error() { echo -e "\033[0;31m====> $*\033[0m"; }
message() { echo -e "\033[0;32m====> $*\033[0m"; }
warning() { echo -e "\033[0;33m====> $*\033[0m"; }

# Check OS
if [[ ! -f /usr/bin/raspi-config ]]; then
  error "Incompatible device!"
  exit 1
fi

# Config
dir=$(dirname "$0")
cfg="$dir/raspinit.cfg"
if [[ ! -f "$cfg" ]]; then
  error "File $cfg not found"
  exit 1
fi

# User
if [[ "$EUID" -ne 0 ]]; then
  error "Root privileges required"
  exit 1
fi

# Functions
enable_tempalias() {
  warning "Creating temp alias..."
  if ! grep -qxF "alias temp='sudo /usr/bin/vcgencmd measure_temp'" /etc/profile; then
    echo -e "\n# Temperature\nalias temp='sudo /usr/bin/vcgencmd measure_temp'" >>/etc/profile
  fi
  echo "%sudo ALL=(ALL) NOPASSWD: /usr/bin/vcgencmd measure_temp" >/etc/sudoers.d/010_temp
  chmod 440 /etc/sudoers.d/010_temp
  message "temp alias added to /etc/profile"
}

disable_swap() {
  warning "Disabling swap..."
  swapoff --all
  apt -y remove dphys-swapfile
  apt -y autoremove
  rm -f /var/swap
  message "Swap disabled"
}

disable_wifi() {
  warning "Disabling Wi-Fi..."
  systemctl disable wpa_supplicant || return 1
  apt purge -y wpasupplicant || return 1
  grep -qxF "dtoverlay=disable-wifi" /boot/firmware/config.txt || echo "dtoverlay=disable-wifi" | tee -a /boot/firmware/config.txt
  message "Wi-Fi disabled"
}

disable_bluetooth() {
  warning "Disabling Bluetooth..."
  systemctl disable hciuart || return 1
  apt purge -y bluez || return 1
  grep -qxF "dtoverlay=disable-bt" /boot/firmware/config.txt || echo "dtoverlay=disable-bt" | tee -a /boot/firmware/config.txt
  message "Bluetooth disabled"
}

disable_modem() {
  warning "Removing ModemManager..."
  apt purge -y modemmanager
  message "ModemManager removed"
}

install_ddclient() {
  warning "Installing ddclient..."
  if [[ ! -f "$dir/config/ddclient.conf" ]]; then
    error "File $dir/config/ddclient.conf not found"
  else
    apt -y install ddclient
    cp "$dir/config/ddclient.conf" /etc/ddclient.conf
    systemctl restart ddclient
    message "ddclient installed"
  fi
}

install_adguard() {
  warning "Installing AdGuard Home..."
  if curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v; then
    message "AdGuard Home installed"
  else
    error "Failed to install AdGuard Home"
  fi
}

install_shairport() {
  warning "Installing shairport-sync"
  if [[ ! -f "$dir/config/shairport.conf" ]]; then
    error "File $dir/config/shairport.conf not found"
  else
    apt -y install shairport-sync
    cp "$dir/config/shairport.conf" /etc/shairport-sync.conf
    echo -e "# Shairport\n0 6 * * * root /usr/bin/systemctl restart shairport-sync.service >/dev/null 2>&1" >/etc/cron.d/shairport
    systemctl restart shairport-sync
    message "shairport-sync installed"
  fi
}

install_log2ram() {
  warning "Installing log2ram..."
  if [[ ! -f "$dir/config/log2ram.conf" ]]; then
    error "File $dir/config/log2ram.conf not found"
  else
    apt -y install rsync log2ram
    cp "$dir/config/log2ram.conf" /etc/log2ram.conf
    message "log2ram installed"
    read -rp "Reboot required. Confirm (y/n): " answer
    case $answer in
      y)
        reboot
        ;;
      *)
        warning "Reboot before installing anything else!"
        ;;
    esac
  fi
}

# Run functions
if [[ -n "$1" ]]; then
  if ! declare -f "$1" >/dev/null; then
    error "No function matches parameter $1"
    exit 1
  fi
  "$1"
else
  apt update || exit 1
  while read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    if ! declare -f "$line" >/dev/null; then
      error "No function matches parameter $line"
      exit 1
    fi
    "$line"
  done <"$cfg"
fi
