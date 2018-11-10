#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_user

# first minimalistic approach

pacman -S --noconfirm \
connman \
lxappearance \
lxqt \
oxygen-icons \
sddm \
wpa_supplicant
