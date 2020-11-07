#!/usr/bin/env bash

pacman -Syu --noconfirm
pacman -S --noconfirm bwm-ng dmidecode htop iotop linux-headers mc namcap p7zip diffutils base-devel reflector
reflector --country France --country Germany --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist