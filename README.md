# Kiosk Linux

Des scripts de configuration pour la mise en place d'un kiosk Linux

> Cette procédure est valable pour une installation sur Waylands, pour une Installation X11 voir [README-xorg.md](README-xorg.md).

## Procedure

On commence par installer le compositeur Waylands de kiosk appelé `cage`

```bash
apt-get install cage xwaland
```

On peut installer les composants audio si besoin

```bash
apt-get install alsa-base alsa-utils alsa-tools pulseaudio
```

Installez les application qui servirons de kiosk, ici ce sera firefox

```bash
apt-get install firefox-esr
```

Commencez par créer un utilisateur non-root qui affichera le kiosk

```bash
useradd -m kiosk -c "Le compte en charge d'afficher l'application de kiosk"
```

On l'ajoute au groupe `audio` pour qu'il puisse controler et diffuser du son et au groupe `tty` pour qu'il puisse interagire avec les consoles virtuelles.

```bash
usermod -aG audio kiosk
usermod -ag tty kiosk
```

On doit ensuite définir l'autologin sur le `tty1` qui permettra le démarrage de l'application de kiosk.
Pour ce faire, on va override le service `getty` (getty est le programme de login sur ubuntu) pour qu'il autologin sur tty1.
On utilise l'option `edit` de `systemctl` pour override le service.
Cela aura pour effet de copier le service contenu dans `/lib/systemd/system/getty@.service` pour le surcharger.

```bash
systemctl edit getty@tty1
```

> Cette opération, peut être efféctuée en créant le fichier `/etc/systemd/system/getty@tty1.service.d/override.conf` et en y ajoutant le contenu donné ci-dessous.

Dans le fichier en édition, on ajoute les lignes permettant d'override l'éxécution de getty.
Il est nécéssaire de laisser une chaine vide pour vider la commande au préalable

```
[Service]
ExecStart=
ExecStart=-/sbin/agetty --noclear -a kiosk %I $TERM
```

Cela aura pour effet de connecter automatiquement notre utilisateur

on doit alors configurer le script `.bash_profile` dans le dossier personnel de l'utilisateur. 
Ce script sera éxécuté lors de la connexion automatique de l'utilisateur.
Il est conseillé de le créer en tant que `root` puis d'autoriser la lecture et l'éxécution a notre utilisateur `kiosk`.

```bash
#!/bin/bash

# On démarre simplement notre compositeur waylands "cage" et l'application associée
# la commande exec permet de remplacer le processus actuel par le serveur x 
# et ainsi éviter le retour au bash si l'application plante

export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export CLUTTER_BACKEND=wayland
export SDL_VIDEODRIVER=wayland

exec cage -s -- firefox --kiosk "http://ltbl.fr/"
```

Ne pas oublier de rendre `.bash_profile` éxécutable

```bash
chmod +xr .bash_profile
```

Enfin, on peut cacher GRUB en éditant la configuration dans `/etc/default/grub`.
ces deux lignes permettent respectivement de mettre à 0 le timeout dans le cas ou le grub est en mode `quiet` et d'activer le mode `quiet` sur le grub.

```
GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=true
```

On exporte alors la configuration pour l'appliquer

```bash
update-grub
```

### Réduire l'attente réseau

Certaines distributions, attendent la connexion réseau 5 minutes avant de démarrer pour garantir cette connexion.
Dans la majorité des cas, cette connexion est plus rapide ou inexistante, il est donc inutile d'attendre 5 minutes.
Pour chager ce timeout, on doit modifier le fichier `/etc/systemd/system/network-online.targets.wants/networking.service`. Ce fichier est en charge de mettre en place la connexion réseau de toutes les interfaces. On doit modifier la valeur de `TimeoutStartSec` de `5min` à `5sec`

```
TimeoutStartSec=5sec
```

### Rotation de l'écran

La rotation de l'écran se fait lors du démarrage de `cage` en ajoutant l'option `-r` pour tourner l'écran de 90 degrés vers la droite. Il peut etre ajouté jusqu'a 3 fois pour obtenir le résultat voulu.

C'est donc dans `.bash_profile` que nous ajoutons cette option

```
exec cage -s -r -- ...
```

### Application Electron

Pour l'utilisation avec Electron, il faut au prealable installer les dépendances.

```bash
apt-get install libgtkextra-dev libgconf2-dev libnss3 libasound2 libxtst-dev
```

Il faut ensuite forcer son utilisation de waylands en créant le fichier `/home/kiosk/.config/electron-flags.conf` avec le contenu suivant.

```
--enable-features=UseOzonePlatform
--ozone-platform=wayland
```

Il suffit alors de démarrer l'application dans le script `.bash_profile`.

## Ressources

* [Configuration des applications pour une compatibilité waylands](https://wiki.archlinux.org/title/Wayland#GUI_libraries)
* [Firefox et thunderbird dasn Waylands](https://blog.szypowi.cz/en/post/ubuntu-wayland/)
* [Bug Ubuntu empechant le démarrage de xorg avec systemd sur les utilisateurs non root](https://bugs.launchpad.net/ubuntu/+source/xinit/+bug/1562219)
* [Annuler l'attente du réseau](https://ubuntuforums.org/showthread.php?t=2323253&p=13488422#post13488422)
* [Problème de boot apres un clonage](https://askubuntu.com/questions/380447/uefi-boot-fails-when-cloning-image-to-new-machine#380564)
