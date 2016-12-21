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
imagemagick \
keepassx \
libreoffice-still \
jdk8-openjdk \
mc

read_input_text "Install VirtualBox Guest Modules?"
if [[ $OPTION == y ]]; then
    pacman -S --noconfirm virtualbox-guest-modules-arch
fi

systemctl enable gdm.service
