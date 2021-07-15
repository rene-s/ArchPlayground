#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh

bail_on_root

if [[ $DESKTOP_SESSION != "gnome" ]]; then
  print_danger "GNOME should be running at this point. It does not, which indicates a previous error."
  exit 1
fi

mkdir -p ~/Bilder

. ./05/009_keymap.sh
. ./05/005_wallpaper.sh
. ./05/006_gnome_settings.sh
. ./05/008_git.sh

# Misc stuff
xdg-mime default org.gnome.Nautilus.desktop inode/directory # see https://wiki.archlinux.de/title/GNOME

. ./05/004_seafile.sh
. ./05/002_appindicator.sh
. ./05/003_misc_tools.sh

# Remove redundant packages
yay -Q vi 2>/dev/null && yay -R --noconfirm vi
yay -Q vim 2>/dev/null && yay -R --noconfirm vim

. ./05/001_tilix_style.sh
. ./05/007_avatar.sh

echo "Done. Continue as shown in the README."
