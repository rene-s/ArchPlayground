#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh
bail_on_root

# Set wallpaper
SCREENS=("1440x900" "1440x1050" "1920x1080" "1600x1200"  "1680x1050" "1920x1200" "2560x1440" "3200x1800" "2560x2048" "1366x768" "4080x768")
URL="https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/img/wallpaper/"

WALLPAPER_DIR="/home/${USER}/Bilder/SDO-Wallpaper"
mkdir -p "$WALLPAPER_DIR"

for screen in "${SCREENS[@]}"; do
  curl -sL "${URL}${screen}_debian-greyish-wallpaper-widescreen.png" --output "${WALLPAPER_DIR}/debian-greyish-wallpaper-widescreen_${screen}.png"
done

DETECTED_SCREEN=$(DISPLAY=:0 xrandr | grep -F '*' | cut -d' ' -f4)
SEEK_WALLPAPER="${WALLPAPER_DIR}/debian-greyish-wallpaper-widescreen_${DETECTED_SCREEN}.png"

if [[ -f $SEEK_WALLPAPER ]]; then
  WALLPAPER=$SEEK_WALLPAPER
else
  WALLPAPER="${WALLPAPER_DIR}/debian-greyish-wallpaper-widescreen_${SCREENS[0]}.png"
fi

# https://wiki.archlinux.org/index.php/GNOME
gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
gsettings set org.gnome.desktop.screensaver picture-uri "file://$WALLPAPER"

# Set screensaver photo
sudo mkdir -p /usr/local/share/pixmaps/wallpaper
sudo cp "$WALLPAPER" /usr/local/share/pixmaps/wallpaper/.sdo_wallpaper.png

GSCHEMA="/usr/share/glib-2.0/schemas/org.gnome.desktop.screensaver.gschema.override"

echo "[org.gnome.desktop.screensaver]" | sudo tee $GSCHEMA
echo "picture-uri=\"/usr/local/share/pixmaps/wallpaper/.sdo_wallpaper.png\"" | sudo tee --append $GSCHEMA
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/