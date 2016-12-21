#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

. ./sharedfuncs.sh

if [ "${USER}" == "root" ]; then
    print_danger "This script is supposed to be run as a user, not as root."
    exit 1
fi

mkdir -p ~/Bilder

# Set X11 keymap
localectl --no-convert set-x11-keymap de pc105 nodeadkeys

# Set wallpaper
WALLPAPER=1366x768_debian-greyish-wallpaper-widescreen.png
wget https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/img/wallpaper/${WALLPAPER} -O /home/${USER}/Bilder/${WALLPAPER}

gsettings set org.gnome.desktop.background picture-uri file:///home/${USER}/Bilder/${WALLPAPER}

# Set avatar
AVATAR="${USER}"
wget https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/img/avatar/${AVATAR}.svg -O /home/${USER}/Bilder/${AVATAR}.svg

cd ~/Bilder/
convert "${USER}.svg" "${USER}.png"

sudo mkdir -p /var/lib/AccountsService/users
USER_FILE=/var/lib/AccountsService/users/${USER}

echo "[User]" | sudo tee $USER_FILE
echo "Language=de_DE.UTF-8" | sudo tee --append $USER_FILE
echo "XSession=" | sudo tee --append $USER_FILE
echo "Icon=/home/${USER}/Bilder/${AVATAR}" | sudo tee --append $USER_FILE
echo "SystemAccount=false" | sudo tee --append $USER_FILE

# Configure git
read -p "Enter your email address: " email
read -p "Enter your name: " nameofuser

git config --global user.email "${email}"
git config --global user.name "${nameofuser}"

sudo chfn -f "${nameofuser}" $USER


