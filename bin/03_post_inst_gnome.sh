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
gnome \
gnome-extra \
gnome-tweak-tool \
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
rhythmbox \
seahorse \
system-config-printer \
vlc \
xorg-xrandr

pacman -R --noconfirm anjuta # not required, gnome confuses opening links with opening anjuga sometimes
pacman -R --noconfirm gnome-music # relies on tracker which in turn als issues with indexing music from symlinks, replaced with good ol' RhythmBox

systemctl enable gdm.service
systemctl enable NetworkManager.service
systemctl enable org.cups.cupsd.service

