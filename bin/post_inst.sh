#!/usr/bin/env bash

# first minimalistic approach

pacman -S gnome gnome-extra gdm virtualbox-guest-modules-arch
systemctl enable gdm.service
pacman -S gnome-tweak-tool