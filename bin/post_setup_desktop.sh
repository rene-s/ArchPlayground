#!/usr/bin/env bash

localectl --no-convert set-x11-keymap de pc105 nodeadkeys

wget https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/img/wallpaper/1366x768_debian-greyish-wallpaper-widescreen.png -O /tmp/wallpaper.png

gsettings set org.gnome.desktop.background picture-uri file:///tmp/wallpaper.png

