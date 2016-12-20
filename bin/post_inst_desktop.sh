#!/usr/bin/env bash

# first minimalistic approach

pacman -S --noconfirm \
chromium \
firefox \
gdm \
git \
gnome \
gnome-extra \
gnome-tweak-tool \
keepassx \
libreoffice-still \
jdk8-openjdk \
mc

read_input_text "Install VirtualBox Guest Modules?"
if [[ $OPTION == y ]]; then
    pacman -S --noconfirm virtualbox-guest-modules-arch
fi

systemctl enable gdm.service
