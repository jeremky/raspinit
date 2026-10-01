# raspinit

A script that automates the post-install configuration of a Raspberry Pi.

## Features

- `enable_tempalias`: adds a `temp` alias to easily get the Raspberry Pi's temperature

- `disable_swap`: disables disk swap, to reduce writes to the SD card. With `rpi-swap` (Raspberry Pi OS Trixie and later), only zram swap is kept (applied on next reboot). With `dphys-swapfile` (older releases), swap is removed entirely

- `disable_wifi`: disables Wi-Fi

- `disable_bluetooth`: disables Bluetooth

- `disable_modem`: removes ModemManager

- `install_ddclient`: installs [ddclient](https://github.com/ddclient/ddclient) (dynamic DNS updates)

- `install_adguard`: installs [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome) (ad blocker)

- `install_shairport`: installs [shairport-sync](https://github.com/mikebrady/shairport-sync) (AirPlay server)

- `install_log2ram`: installs [log2ram](https://github.com/azlux/log2ram) (reduces writes to the SD card)

## Configuration

The `config/config.cfg` file lets you configure how the script runs to suit your preferences.
Comment out the functions you don't want to use. Example:

```txt
# raspinit config

enable_tempalias
disable_swap

disable_wifi
disable_bluetooth
disable_modem

# install_ddclient
# install_adguard
install_shairport
install_log2ram
```

> **Important**: `install_log2ram` must be placed at the end of the file, because its installation requires a reboot. Any actions listed after it won't run.

### Application configuration

For `ddclient`, `shairport-sync` and `log2ram`, you need to prepare the matching files in the `config` directory (`ddclient.conf`, `shairport.conf`, `log2ram.conf`).
These files are copied to `/etc` when the matching install function runs.

> `install_adguard` doesn't need any config file: it installs directly via the official AdGuard Home script.

## Usage

Once you've edited `config/config.cfg`, run the script with root privileges:

```bash
sudo ./raspinit.sh
```

> If log2ram installation is enabled, you'll be asked to reboot after it's installed

If something goes wrong or you forgot a step, you can run a specific action by passing it as an argument. For example, to only install AdGuardHome:

```bash
sudo ./raspinit.sh install_adguard
```
