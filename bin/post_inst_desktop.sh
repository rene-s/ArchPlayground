#!/usr/bin/env bash

# first minimalistic approach

pacman -S --noconfirm \
chromium \
firefox \
gdm \
gnome \
gnome-extra \
gnome-tweak-tool \
jdk8-openjdk \
virtualbox-guest-modules-arch

systemctl enable gdm.service
