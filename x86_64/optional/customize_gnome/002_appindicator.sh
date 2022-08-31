#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../../lib/sharedfuncs.sh"
bail_on_root

# Install and enable AppIndicator support
yay -R gnome-shell-extension-appindicator-git 2>/dev/null
yay -Q gnome-shell-extension-appindicator 2>/dev/null
RET=$?

if [[ "${RET}" != "0" ]]; then
  yay -S --noconfirm gnome-shell-extension-appindicator # activate: tweaks > extensions > Kstatusnotifieritem
fi

gsettings set org.gnome.shell enabled-extensions "['appindicatorsupport@rgcjonas.gmail.com','window-list@gnome-shell-extensions.gcampax.github.com']"

# List of GNOME extensions:
# ls /usr/share/gnome-shell/extensions/

# Get enabled GNOME extensions:
# gsettings get org.gnome.shell enabled-extensions