#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_root

PRODUCT_NAME=`cat /sys/devices/virtual/dmi/id/product_name`

mkdir -p ~/Bilder

# Set X11 keymap
localectl --no-convert set-x11-keymap de pc105 nodeadkeys
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'de')]"

# Set wallpaper
SCREENS=( `xrandr | fgrep '*' | cut -d' ' -f4` "1366x768" )
URL="https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/img/wallpaper/"

WALLPAPER="/home/${USER}/Bilder/.sdo_wallpaper.png"
wget ${URL}${SCREENS[0]}_debian-greyish-wallpaper-widescreen.png -O $WALLPAPER

if [ $? != 0 ]; then
  wget ${URL}${SCREENS[1]}_debian-greyish-wallpaper-widescreen.png -O $WALLPAPER
fi

gsettings set org.gnome.desktop.background picture-uri file://$WALLPAPER
gsettings set org.gnome.desktop.screensaver picture-uri file://$WALLPAPER

# see http://fabhax.com/technology/change-wallpapers-in-gnome-3.4/

# Set screensaver photo
sudo mkdir -p /usr/local/share/pixmaps/wallpaper
sudo cp $WALLPAPER /usr/local/share/pixmaps/wallpaper/.sdo_wallpaper.png

GSCHEMA="/usr/share/glib-2.0/schemas/org.gnome.desktop.screensaver.gschema.override"

echo "[org.gnome.desktop.screensaver]" | sudo tee $GSCHEMA
echo "picture-uri=\"/usr/local/share/pixmaps/wallpaper/.sdo_wallpaper.png\"" | sudo tee --append $GSCHEMA
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

# Set avatar
AVATAR="${USER}"
wget https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/img/avatar/${AVATAR}.svg -O /home/${USER}/Bilder/.${AVATAR}.svg

sudo mkdir -p /var/lib/AccountsService/users
sudo mkdir -p /usr/local/share/pixmaps/faces

cd ~/Bilder/
convert ".${USER}.svg" ".${USER}.png"

# Scale avatar to 96px width, then crop 96x96px with 5px offset from the top. Save to non-home dir because GDM does not seem to like those.
sudo convert ".${USER}.png" -resize 96x -crop 96x96+0+5 "/usr/local/share/pixmaps/faces/${USER}.png"

USER_FILE=/var/lib/AccountsService/users/${USER}

echo "[User]" | sudo tee $USER_FILE
echo "Language=de_DE.UTF-8" | sudo tee --append $USER_FILE
echo "XSession=" | sudo tee --append $USER_FILE
echo "Icon=/usr/local/share/pixmaps/faces/${USER}.png" | sudo tee --append $USER_FILE
echo "SystemAccount=false" | sudo tee --append $USER_FILE

# Configure git
read -p "Enter your email address: " email
read -p "Enter your name: " nameofuser

git config --global user.email "${email}"
git config --global user.name "${nameofuser}"

# Misc stuff
sudo chfn -f "${nameofuser}" $USER # Set name of user
xdg-mime default org.gnome.Nautilus.desktop inode/directory # see https://wiki.archlinux.de/title/GNOME

# Install AUR packages
yaourt -S seafile-client
yaourt -S rts_bpp-dkms-git
yaourt -S gnome-shell-extension-appindicator-git # activate: tweaks > extensions > Kstatusnotifieritem

# P640RF=Tuxedo XC1406, 4180W15=Lenovo T420
if [ $PRODUCT_NAME == "P640RF" ]; then
    yaourt -S tuxedo-wmi-dkms
    # https://www.linux-onlineshop.de/forum/index.php?page=Thread&threadID=26
    sed -i -- "s/^#tuxedo-wmi/tuxedo-wmi/g" /etc/modules-load.d/sdo-modules.conf
fi

