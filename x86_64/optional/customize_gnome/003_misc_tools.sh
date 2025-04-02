#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../../lib/sharedfuncs.sh"
bail_on_root

# Install other useful items
yay_inst_pkg bind
yay_inst_pkg oh-my-zsh-git
yay_inst_pkg solaar
yay_inst_pkg nextcloud-client
yay_inst_pkg libfido2
yay_inst_pkg yubikey-manager
yay_inst_pkg yubikey-personalization
yay_inst_pkg bluez
yay_inst_pkg bluez-utils
yay_inst_pkg librewolf-bin
yay_inst_pkg keepassxc
yay_inst_pkg btop 

sudo systemctl enable --now bluetooth.service
yay -S --noconfirm ttf-roboto noto-fonts noto-fonts-cjk adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts ttf-dejavu

mkdir -p ~/.config/autostart
