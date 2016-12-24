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
firefox \
gdm \
gimp \
git \
gnome \
gnome-extra \
gnome-tweak-tool \
guake \
imagemagick \
intellij-idea-community-edition \
keepass \
kernel-headers \
libreoffice-still \
jdk8-openjdk \
mc \
modemmanager \
namcap \
networkmanager \
networkmanager-openvpn \
network-manager-applet \
openssh \
seahorse \
xorg-xrandr

VM=`dmidecode -s system-product-name`
if [[ $VM == "VirtualBox" ]]; then
    pacman -S --noconfirm virtualbox-guest-modules-arch
fi

systemctl enable gdm.service
systemctl enable NetworkManager.service