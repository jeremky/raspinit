#!/bin/bash

# Colored messages
error() { echo -e "\033[0;31m❯ $*\033[0m"; }
message() { echo -e "\033[0;36m──────────\033[0m\n\033[0;32m❱ $*\033[0m"; }
warning() { echo -e "\033[0;33m❱ $*\033[0m\n\033[0;36m──────────\033[0m"; }

# Check OS
if [[ ! -f /usr/bin/raspi-config ]]; then
  error "This script requires a Raspberry Pi (raspi-config)"
  exit 1
fi

# Check root privileges
if [[ "$EUID" -ne 0 ]]; then
  error "Root privileges required"
  exit 1
fi

# Functions
enable_tempalias() {
  warning "Creating temp alias"
  if ! grep -qxF "alias temp='sudo /usr/bin/vcgencmd measure_temp'" /etc/profile; then
    echo -e "\n# Temperature\nalias temp='sudo /usr/bin/vcgencmd measure_temp'" >>/etc/profile || {
      error "Failed to write /etc/profile"
    }
  fi
  echo "%sudo ALL=(ALL) NOPASSWD: /usr/bin/vcgencmd measure_temp" >/etc/sudoers.d/010_temp || {
    error "Failed to write /etc/sudoers.d/010_temp"
  }
  chmod 440 /etc/sudoers.d/010_temp || {
    error "Failed to chmod /etc/sudoers.d/010_temp"
  }
  message "temp alias added to /etc/profile"
  echo
}

disable_swap() {
  warning "Disabling disk swap"
  if dpkg -s rpi-swap >/dev/null 2>&1; then
    mkdir -p /etc/rpi/swap.conf.d
    echo -e "[Main]\nMechanism=zram" | tee /etc/rpi/swap.conf.d/raspinit.conf || {
      error "Failed to write /etc/rpi/swap.conf.d/raspinit.conf"
      return 1
    }
    message "Disk swap disabled (zram only). Applied on next reboot"
  elif dpkg -s dphys-swapfile >/dev/null 2>&1; then
    swapoff --all
    apt -y remove dphys-swapfile || {
      error "Error while removing dphys-swapfile"
    }
    apt -y autoremove
    rm -f /var/swap
    message "Swap disabled"
  else
    error "No supported swap manager found (rpi-swap or dphys-swapfile)"
    return 1
  fi
  echo
}

disable_wifi() {
  warning "Disabling Wi-Fi"
  systemctl disable wpa_supplicant || {
    error "Error while disabling wpa_supplicant"
  }
  apt -y purge wpasupplicant || {
    error "Error while removing wpasupplicant"
  }
  grep -qxF "dtoverlay=disable-wifi" /boot/firmware/config.txt || echo "dtoverlay=disable-wifi" | tee -a /boot/firmware/config.txt
  message "Wi-Fi disabled"
  echo
}

disable_bluetooth() {
  warning "Disabling Bluetooth"
  apt -y purge bluez || {
    error "Error while removing bluez"
  }
  grep -qxF "dtoverlay=disable-bt" /boot/firmware/config.txt || echo "dtoverlay=disable-bt" | tee -a /boot/firmware/config.txt
  message "Bluetooth disabled"
  echo
}

disable_modem() {
  warning "Removing ModemManager"
  apt -y purge modemmanager || {
    error "Error while removing ModemManager"
    return 1
  }
  message "ModemManager removed"
  echo
}

install_ddclient() {
  if [[ ! -f "$dir/ddclient.conf" ]]; then
    error "File $dir/ddclient.conf not found"
    return 1
  fi
  if apt -y install ddclient; then
    warning "Configuring ddclient"
    cp "$dir/ddclient.conf" /etc/ddclient.conf
    systemctl restart ddclient || {
      error "Error while restarting ddclient"
    }
    message "ddclient installed"
    echo
  fi
}

install_adguard() {
  warning "Installing AdGuard Home"
  local script
  script=$(curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh) || {
    error "Error while downloading the AdGuard Home install script"
    return 1
  }
  sh -s -- -v <<<"$script" || {
    error "Error while installing AdGuard Home"
    return 1
  }
  message "AdGuard Home installed"
  echo
}

install_shairport() {
  if [[ ! -f "$dir/shairport.conf" ]]; then
    error "File $dir/shairport.conf not found"
    return 1
  fi
  if apt -y install shairport-sync; then
    warning "Configuring shairport-sync"
    cp "$dir/shairport.conf" /etc/shairport-sync.conf
    echo -e "# Shairport\n0 6 * * * root /usr/bin/systemctl restart shairport-sync.service >/dev/null 2>&1" >/etc/cron.d/shairport
    systemctl restart shairport-sync || {
      error "Error while restarting shairport-sync"
    }
    message "shairport-sync installed"
    echo
  fi
}

install_log2ram() {
  if [[ ! -f "$dir/log2ram.conf" ]]; then
    error "File $dir/log2ram.conf not found"
    return 1
  fi
  if apt -y install rsync log2ram; then
    warning "Configuring log2ram"
    cp "$dir/log2ram.conf" /etc/log2ram.conf
    message "log2ram installed"
    echo
    read -rp "Reboot required. Reboot now? (y/n): " answer </dev/tty
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

# Execution
dir="$(dirname "$0")/config"
cfg="$dir/config.cfg"
if [[ ! -f "$cfg" ]]; then
  error "File $cfg not found"
  exit 1
fi

if [[ -n "$1" ]]; then
  if ! declare -f "$1" >/dev/null; then
    error "No function matches parameter $1"
    exit 1
  fi
  "$1"
  exit
fi

warning "Updating packages"
apt update || {
  error "Error while updating packages"
  exit 1
}
echo

while read -r line; do
  [[ -z "$line" || "$line" == \#* ]] && continue
  if ! declare -f "$line" >/dev/null; then
    error "No function matches parameter $line"
    exit 1
  fi
  "$line"
done <"$cfg"
