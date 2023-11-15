#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../lib/sharedfuncs.sh"
bail_on_root

yay_inst_pkg reflector

sudo tee /etc/xdg/reflector/reflector.conf <<EOF
--save /etc/pacman.d/mirrorlist
--country Germany
--protocol https
--latest 5
EOF

sudo systemctl enable --now reflector.service