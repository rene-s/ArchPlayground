#!/usr/bin/env bash

# Install and enable AppIndicator support
yay -R gnome-shell-extension-appindicator-git
yay -Q gnome-shell-extension-appindicator
RET=$?

if [[ $RET != "0" ]]; then
  yay -S --noconfirm ggnome-shell-extension-appindicator # activate: tweaks > extensions > Kstatusnotifieritem
  gsettings set org.gnome.shell enabled-extensions "['appindicatorsupport@rgcjonas.gmail.com','window-list@gnome-shell-extensions.gcampax.github.com']"
fi
