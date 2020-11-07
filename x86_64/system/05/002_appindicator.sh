#!/usr/bin/env bash

# Install and enable AppIndicator support
yay -Q gnome-shell-extension-appindicator-git
RET=$?

if [[ $RET != "0" ]]; then
  yay -S --noconfirm gnome-shell-extension-appindicator-git # activate: tweaks > extensions > Kstatusnotifieritem
  gsettings set org.gnome.shell enabled-extensions "['appindicatorsupport@rgcjonas.gmail.com','window-list@gnome-shell-extensions.gcampax.github.com']"
fi
