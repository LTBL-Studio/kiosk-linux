# Kiosk Linux

Des scripts de configuration pour la mise en place d'un kiosk Linux

## Procedure

On commence par installer le server X

```bash
apt-get install xorg xserver-xorg-legacy
```

On reconfigure le serveur Legacy pour qu'il autorise un quelconque utilisateur a démarrer le serveur x.
On peux alors choisir "n'importe qui" dans le menu qui s'affiche.

```bash
dpkg-reconfigure xserver-xorg-legacy
```

> Cette opération peut aussi être éfféctuée en modifiant le fichier `/etc/X11/Xwrapper.config`.
> On remplace la valeur de `allowed_users` par `anybody`.
> ```
> allowed_users=anybody
> ```

On installe un gestionnaire de fenêtres minimal comme `lwm`

```bash
apt-get install lwm
```

Puis on installe les composants audio

```bash
apt-get install alsa-base alsa-utils alsa-tools pulseaudio
```

Installez les application qui servirons de kiosk, ici ce sera chromium

```bash
apt-get install chromium browser
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

# On démarre simplement un serveur X en session standard avec le script "kiosk_start.sh"
# la commande exec permet de remplacer le processus actuel par le serveur x 
# et ainsi éviter le retour au bash si l'application plante
exec startx /etc/X11/Xsession ./kiosk_start.sh
```

Comme donné dans le script précédent, on doit alors créer le script de démarrage pour configurer le serveur X et l'application à démarrer.
De même que le script précédent, il est conseillé de le créer en tant que `root` puis d'autoriser la lecture et l'éxécution a notre utilisateur `kiosk`.

```bash
#!/bin/bash
# On annule l'économie d'énergie et la mise en veille de l'ecran
xset -dpms
xset s off
# On active les drivers audio
start-pulseaudio-x11
# On démarre en arrière plan le gestionnaire de fenêtres
lwm &
# On attend que le gestionnaire soit ouvert
sleep 1
# On démarre l'application de kiosk (ici chromium)
chromium-browser --kiosk --inconito "http://duckduckgo.com"
```

On doit alors mettre a disposition de notre utilisateur les scripts.
Pour ce faire on leur ajoute le droit de lecture pour tout les utilisateurs.

```bash
chmod +xr .bash_profile kiosk_start.sh
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

### Cacher le curseur de la souris

Pour cacher le curseur de la souris on utilisera le package `unclutter`

```bash
apt-get install unclutter
```

On ajoute alors à notre script `kiosk_start.sh` la commande permettant de cacher le curseulr apres 0.01 secondes même si le curseur est à la racine.

```bash
unclutter -idle "0.01" -root
```

### Réduire l'attente réseau

Certaines distributions, attendent la connexion réseau 5 minutes avant de démarrer pour garantir cette connexion.
Dans la majorité des cas, cette connexion est plus rapide ou inexistante, il est donc inutile d'attendre 5 minutes.
Pour chager ce timeout, on doit modifier le fichier `/etc/systemd/system/network-online.targets.wants/networking.service`. Ce fichier est en charge de mettre en place la connexion réseau de toutes les interfaces. On doit modifier la valeur de `TimeoutStartSec` de `5min` à `5sec`

```
TimeoutStartSec=5sec
```

### Rotation de l'écran

La rotation de l'écran fait intervenir la configuration du serveur X que vous trouverez dans `/etc/X11/xorg.conf`.
Si cette configuration n'existe pas, créez là avec le squelette suivant.

```
Section "Device"
        Identifier      "main-device"
EndSection

Section "Monitor"
        Identifier      "main-monitor"
EndSection

Section "Screen"
        Identifier      "main-screen"
        Monitor         "main-monitor"
        Device          "main-device"
EndSection
```

On peut alors éfféctuer une rotation vers la droite (`Right`) vers la gauche (`Left`) ou complètement retourner l'écran (`inverted`) en spécifiant l'option `Rotate` dans la section `Monitor`

```
Option "Rotate" "Right"
```

Si l'ecran dispose d'un ecran tactile, il faut créer un nouvelle section `InputClass` pour ce type de materiel que l'on séléctionne avec `MatchIsTouchscreen` à `1`.

```
Section "InputClass"
        Identifier              "touchscreen"
        MatchIsTouchscreen      "1"
EndSection
```

On doit alors échanger les axes avec l'option `SwapAxes`

```
Option  "SwapAxes"      "1"
```

Selon les cas on peut être amené a inverser les axes.
Cela ce fait avec les options `InvertX` et `InvertY`

```
Option  "InvertX"       "0"
Option  "InvertY"       "1"
```

### Application Electron

Pour l'utilisation avec Electron, il faut au prealable installer les dépendances.

```bash
apt-get install libgtkextra-dev libgconf2-dev libnss3 libasound2 libxtst-dev
```

Il suffit alors de démarrer l'application dans le script `kiosk_start.sh`.

## Ressources

* [Configuration d'in ecran tactile dans xorg.conf](https://www.plop.at/en/touchscreen.html)
* [Bug Ubuntu empechant le démarrage de xorg avec systemd sur les utilisateurs non root](https://bugs.launchpad.net/ubuntu/+source/xinit/+bug/1562219)
* [Annuler l'attente du réseau](https://ubuntuforums.org/showthread.php?t=2323253&p=13488422#post13488422)
