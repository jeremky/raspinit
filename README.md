# raspinit.sh

Script post installation pour Raspberry Pi. Il permet d'automatiser la configuration de certains éléments de votre carte :

- Désactive le swap, afin de limiter les écritures sur la carte SD

- Ajoute un alias `temp` pour obtenir la température du raspberry

- Désactive le Wifi et le Bluetooth

- Installe [Log2Ram](https://github.com/azlux/log2ram), un outil permettant de stocker le répertoire `/var/log` en ram, afin de limiter les écritures sur la carte SD

- Installe Adguard Home

- Installe ddclient

## Configuration

Un fichier de configuration `raspinit.cfg` permet de paramétrer l'exécution du script selon vos préférences : 

```txt
# raspinit config
swap=off

# apps
log2ram=on
adguard=on
ddclient=on

# Network
wifi=off
bluetooth=off
```

## Exécution

Une fois le fichier `raspinit.cfg` modifié, lancez le script avec les droits root :

```bash
sudo ./raspinit.sh
```

> Si Log2Ram est activé, il vous sera demandé de redémarrer après installation
