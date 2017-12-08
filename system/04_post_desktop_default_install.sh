#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

PRODUCT_NAME=`cat /sys/devices/virtual/dmi/id/product_name`

bail_on_user

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
imagemagick \
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
qt4 \
rhythmbox \
seahorse \
sane \
system-config-printer \
vlc \
xorg-xbacklight \
xorg-xrandr \
xsel

# notes:
# xsel enables KeePass to write stuff to the clipboard

# P640RF=Tuxedo XC1406, 4180W15=Lenovo T420
if [ $PRODUCT_NAME == "P640RF" ] || [ $PRODUCT_NAME == "4180W15" ]; then
    pacman -S --noconfirm \
        bbswitch-dkms \
        bumblebee \
        mesa-demos \
        primus \
        virtualgl

    systemctl enable bumblebeed.service

    sudo usermod -a -G bumblebee re
    sudo usermod -a -G bumblebee st
fi

pacman -R --noconfirm anjuta # not required, gnome confuses opening links with opening anjuga sometimes
pacman -R --noconfirm gnome-music # relies on tracker which in turn has issues with indexing music from symlinks, replaced with good ol' RhythmBox

systemctl enable gdm.service
systemctl enable NetworkManager.service
systemctl enable org.cups.cupsd.service

# Prepare for IntelliJ IDEA/PhpStorm; see https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
echo "fs.inotify.max_user_watches = 524288" > /etc/sysctl.d/inotify.conf

# Fix wrong permissions; fixes GDM sometimes not starting after installation
chown -R gdm:gdm /var/lib/gdm/

# Set up bluetooth support
read -p "Set up bluetooth support? (y/N): " BLUETOOTH

if [[ $BLUETOOTH == "y" ]]
then
    setup_bluetooth
fi
