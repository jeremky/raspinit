# raspinit

Script post installation pour Raspberry Pi. Il permet d'automatiser la configuration de certains éléments de votre carte :

- Ajoute un alias `temp` pour obtenir facilement la température du Raspberry Pi

- Désactive le swap, afin de limiter les écritures sur la carte SD

- Désactive le Wifi et le Bluetooth

- Supprime Modem Manager

- Permet d'installer les applications suivantes :

  - [log2ram](https://github.com/azlux/log2ram) : réduction des écritures sur la SD

  - [AdGuardHome](https://github.com/AdguardTeam/AdGuardHome) : bloqueur de pubs

  - [ddclient](https://github.com/ddclient/ddclient) : mise à jour DNS dynamique

  - [shairport-sync](https://github.com/mikebrady/shairport-sync) : serveur AirPlay

## Configuration

Un fichier de configuration `raspinit.cfg` permet de paramétrer l'exécution du script selon vos préférences.
Commentez les fonctions que vous ne voulez pas utiliser :

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

> **Important** : `install_log2ram` doit être placé en fin de fichier, car son installation nécessite un redémarrage. Les actions suivantes ne seront pas exécutées après un redémarrage.

### Configuration des applications

Pour les applications `ddclient`, `shairport-sync` et `log2ram`, vous devez préparer les fichiers présents dans le sous dossier `config`.
Si la fonction d'installation est appelée, ce sont ces fichiers qui seront copiés dans `/etc` lors de l'installation.

> `install_adguard` ne nécessite aucun fichier de configuration : l'installation se fait directement via le script officiel AdGuard Home.

## Exécution

Une fois le fichier `raspinit.cfg` modifié, lancez le script avec les droits root :

```bash
sudo ./raspinit.sh
```

> Si l'installation de log2ram est activé, un redémarrage vous sera demandé après son installation

Il est possible, en cas de problème ou d'oubli, d'exécuter une action spécifique, en passant le processus en paramètre. Par exemple, si vous voulez seulement installer AGuardHome :

```bash
sudo ./raspinit.sh install_adguard
```
