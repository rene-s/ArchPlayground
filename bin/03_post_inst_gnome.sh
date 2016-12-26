#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

. ./sharedfuncs.sh

if [ "${USER}" != "root" ]; then
    print_danger "This script is supposed to be run as root, not as user."
    exit 1
fi

# first minimalistic approach

pacman -S --noconfirm \
chromium \
cups \
eog \
firefox \
gdm \
gimp \
git \
gnome \
gnome-extra \
gnome-tweak-tool \
gst-plugins-ugly \
guake \
imagemagick \
intellij-idea-community-edition \
keepass \
libreoffice-still \
libu2f-host \
linux-headers \
jdk8-openjdk \
mc \
modemmanager \
namcap \
networkmanager \
networkmanager-openvpn \
network-manager-applet \
openssh \
p7zip \
rhythmbox \
seahorse \
system-config-printer \
vlc \
xorg-xrandr

pacman -R --noconfirm \
anjuta \
gnome-music

VM=`dmidecode -s system-product-name`
if [[ $VM == "VirtualBox" ]]; then
    pacman -S --noconfirm virtualbox-guest-modules-arch
else
    pacman -S --noconfirm virtualbox
fi

systemctl enable gdm.service
systemctl enable NetworkManager.service

install_yaourt

