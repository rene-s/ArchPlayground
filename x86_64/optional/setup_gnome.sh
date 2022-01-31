#!/usr/bin/env bash

# This script sets up a user account. Sets up zsh as default shell.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh

bail_on_user

pacman -Sy --noconfirm gdm \
                       gimp \
                       gnome \
                       gnome-tweaks \
                       gnome-shell-extensions \
                       nautilus \
                       notepadqq \
                       vlc \
                       tilix

#   networkmanager-wireguard-git
#   wireguard-lts

systemctl enable gdm.service --now
chown -R gdm:gdm /var/lib/gdm/

# Install and enable AppIndicator support
pacman -Q gnome-shell-extension-appindicator
RET=$?

if [[ $RET != "0" ]]; then
  pacman -S --noconfirm gnome-shell-extension-appindicator # activate: tweaks > extensions > Kstatusnotifieritem
  #gsettings set org.gnome.shell enabled-extensions "['appindicatorsupport@rgcjonas.gmail.com','window-list@gnome-shell-extensions.gcampax.github.com']"
fi

pacman -Q solaar || pacman -S --noconfirm solaar
pacman -Q flameshot || pacman -S --noconfirm flameshot # also profits from AppIndicator support

pacman -Q anjuta 2>/dev/null && pacman -R --noconfirm anjuta || true           # not required, gnome confuses opening links with opening anjuta sometimes
pacman -Q gnome-music 2>/dev/null && pacman -R --noconfirm gnome-music || true # relies on tracker which in turn has issues with indexing music from symlinks, replaced with Lollypop

# pacman-key --refresh