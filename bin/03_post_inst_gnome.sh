#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

. ./sharedfuncs.sh

PRODUCT_NAME=`cat /sys/devices/virtual/dmi/id/product_name`

if [ "${USER}" != "root" ]; then
    print_danger "This script is supposed to be run as root, not as user."
    exit 1
fi

# first minimalistic approach

pacman -S --noconfirm \
chromium \
cups \
eog \
exfat-utils \
firefox \
gdm \
gimp \
gnome \
gnome-extra \
gnome-tweak-tool \
gnome-user-share \
gst-plugins-ugly \
gtk3-print-backends \
guake \
imagemagick \
intellij-idea-community-edition \
keepass \
libreoffice-still \
libu2f-host \
linux-headers \
jdk8-openjdk \
modemmanager \
networkmanager \
networkmanager-openvpn \
network-manager-applet \
ntfs-3g \
pavucontrol \
rhythmbox \
seahorse \
system-config-printer \
vlc \
xorg-xbacklight \
xorg-xrandr

if [ $PRODUCT_NAME == "P640RF" ]; then
    pacman -S --noconfirm \
        bbswitch-dkms \
        bumblebee \
        lib32-virtualgl \
        lib32-nvidia-utils \
        lib32-nvidia-340xx-util \
        lib32-mesa-libgl \
        mesa-demos \
        nvidia-libgl \
        nvidia-340xx-libgl \
        primus \
        virtualgl

    systemctl enable bumblebee.service

    useradd -m -g bumblebee re
    useradd -m -g bumblebee st
fi

pacman -R --noconfirm anjuta # not required, gnome confuses opening links with opening anjuga sometimes
pacman -R --noconfirm gnome-music # relies on tracker which in turn als issues with indexing music from symlinks, replaced with good ol' RhythmBox

systemctl enable gdm.service
systemctl enable NetworkManager.service
systemctl enable org.cups.cupsd.service

# Set up bluetooth support
read -p "Set up bluetooth support? (y/N): " BLUETOOTH

if [[ BLUETOOTH == "y" ]]
then
    setup_bluetooth
fi

# Prepare for IntelliJ IDEA/PhpStorm; see https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
echo "fs.inotify.max_user_watches = 524288" > /etc/sysctl.d/inotify.conf
