# This script customizes GNOME

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh

bail_on_root

if [[ $DESKTOP_SESSION != "gnome" ]]; then
  echo "This script needs to be run in a GNOME session. Log into GNOME and retry."
  exit 1
fi

mkdir -p ~/Bilder

. ./customize_gnome/009_keymap.sh
. ./customize_gnome/005_wallpaper.sh
. ./customize_gnome/006_gnome_settings.sh
. ./customize_gnome/008_git.sh

# Misc stuff
xdg-mime default org.gnome.Nautilus.desktop inode/directory # see https://wiki.archlinux.de/title/GNOME

. ./customize_gnome/004_seafile.sh
. ./customize_gnome/002_appindicator.sh
. ./customize_gnome/003_misc_tools.sh

# Remove redundant packages
pacman -Q vi 2>/dev/null && pacman -R --noconfirm vi || true
pacman -Q vim 2>/dev/null && pacman -R --noconfirm vim || true

. ./customize_gnome/001_tilix_style.sh
. ./customize_gnome/007_avatar.sh
