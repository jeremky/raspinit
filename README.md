# raspinit.sh

Script post installation pour Raspberry Pi. Il permet d'automatiser la configuration de certains éléments de votre carte :

- Désactive le swap

- Ajoute un alias `temp` pour obtenir la température du raspberry

- Désactive le Wifi et le Bluetooth

- Installe Log2Ram

## Configuration

Un fichier de configuration `raspinit.cfg` permet de paramétrer l'exécution du script selon vos préférences : 

```txt
# raspinit config
swap=off
log2ram=on

# Network
wifi=off
bluetooth=off
```

## Exécution

Une fois le fichier `raspinit.cfg` modifié, lancez le script avec les droits root :

```bash
sudo ./raspinit.sh
```

## Log2Ram

[Log2Ram](https://github.com/azlux/log2ram) est un outil permettant de stocker les répertoires des logs en ram, afin de limiter les écritures sur la carte SD.

Si la variable `log2ram` est sur `on` dans le fichier `raspinit.cfg`, le script sera automatiquement exécuté. Il vous sera demandé de redémarrer, comme spécifié par son créateur.
