# raspinit

A post-install script for Raspberry Pi. It automates the configuration of several parts of your board:

- Adds a `temp` alias to easily get the Raspberry Pi's temperature

- Disables swap, to reduce writes to the SD card

- Disables Wi-Fi and Bluetooth

- Removes ModemManager

- Can install the following applications:

  - [log2ram](https://github.com/azlux/log2ram): reduces writes to the SD card

  - [AdGuardHome](https://github.com/AdguardTeam/AdGuardHome): ad blocker

  - [ddclient](https://github.com/ddclient/ddclient): dynamic DNS updates

  - [shairport-sync](https://github.com/mikebrady/shairport-sync): AirPlay server

## Configuration

The `raspinit.cfg` config file lets you configure how the script runs to suit your preferences.
Comment out the functions you don't want to use:

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

> **Important**: `install_log2ram` must be placed at the end of the file, because its installation requires a reboot. Any following actions won't run after the reboot.

### Application configuration

For `ddclient`, `shairport-sync` and `log2ram`, you need to prepare the files in the `config` subdirectory.
When the install function is called, these files are copied to `/etc` during installation.

> `install_adguard` doesn't need any config file: it installs directly via the official AdGuard Home script.

## Running

Once you've edited `raspinit.cfg`, run the script with root privileges:

```bash
sudo ./raspinit.sh
```

> If log2ram installation is enabled, you'll be asked to reboot after it's installed

If something goes wrong or you forgot a step, you can run a specific action by passing it as an argument. For example, to only install AdGuardHome:

```bash
sudo ./raspinit.sh install_adguard
```
