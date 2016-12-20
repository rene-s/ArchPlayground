#!/usr/bin/env bash

# first minimalistic approach

pacman -S --noconfirm gnome gnome-extra gdm virtualbox-guest-modules-arch
systemctl enable gdm.service
pacman -S --noconfirm gnome-tweak-tool