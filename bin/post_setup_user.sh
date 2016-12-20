#!/usr/bin/env bash

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

echo "[User]" > $USER_FILE
echo "Language=de_DE.UTF-8" >> $USER_FILE
echo "XSession=" >> $USER_FILE
echo "Icon=/home/${USER}/Bilder/${AVATAR}" >> $USER_FILE
echo "SystemAccount=false" >> $USER_FILE

# Configure git
read -p "Enter your email address: " email
read -p "Enter your name: " nameofuser

git config user.email "${email}"
git config user.name "${nameofuser}"

