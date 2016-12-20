#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

. ./sharedfuncs.sh

# Set X11 keymap
localectl --no-convert set-x11-keymap de pc105 nodeadkeys

# Set wallpaper
WALLPAPER=1366x768_debian-greyish-wallpaper-widescreen.png
wget https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/img/wallpaper/${WALLPAPER} -O /home/${USER}/Bilder/${WALLPAPER}

gsettings set org.gnome.desktop.background picture-uri file:///home/${USER}/Bilder/${WALLPAPER}

# Set avatar
AVATAR="${USER}.svg"
wget https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/img/avatar/${AVATAR} -O /home/${USER}/Bilder/${AVATAR}

sudo mkdir /var/lib/AccountsService/users
USER_FILE=/var/lib/AccountsService/users/${USER}

sudo echo "[User]" > $USER_FILE
sudo echo "Language=de_DE.UTF-8" >> $USER_FILE
sudo echo "XSession=" >> $USER_FILE
sudo echo "Icon=/home/${USER}/Bilder/${AVATAR}" >> $USER_FILE
sudo echo "SystemAccount=false" >> $USER_FILE

# Configure git
read -p "Enter your email address: " email
read -p "Enter your name: " nameofuser

git config user.email "${email}"
git config user.name "${nameofuser}"

