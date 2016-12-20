#!/usr/bin/env bash

# first minimalistic approach

pacman -S gnome gnome-extra
systemctl enable gdm.service
pacman -S gnome-tweak-tool