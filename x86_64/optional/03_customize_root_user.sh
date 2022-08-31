#!/usr/bin/env bash

# This script customizes the root account.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../lib/sharedfuncs.sh"
bail_on_user

pacman -Q zsh 2>/dev/null || pacman -Sy --noconfirm zsh

URL_ZSHRC="https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/cfg/_zshrc"
curl -L "$URL_ZSHRC" --output "/tmp/.zshrc"
echo 'export PATH=$PATH:/opt/vc/bin' >> "/tmp/.zshrc"

cp /tmp/.zshrc /root/.zshrc
chown "root:root" "/root/.zshrc"
chsh -s /usr/bin/zsh "root"
