#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh
bail_on_root

gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.calendar show-weekdate true
gsettings set org.gnome.desktop.interface enable-hot-corners false
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"