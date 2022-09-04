#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../../lib/sharedfuncs.sh"
bail_on_root

# Install and enable AppIndicator support
yay -R gnome-shell-extension-appindicator-git 2>/dev/null
yay_inst_pkg gnome-shell-extension-appindicator

gsettings set org.gnome.shell enabled-extensions "['appindicatorsupport@rgcjonas.gmail.com','window-list@gnome-shell-extensions.gcampax.github.com']"

# List of GNOME extensions:
# ls /usr/share/gnome-shell/extensions/

# Get enabled GNOME extensions:
# gsettings get org.gnome.shell enabled-extensions