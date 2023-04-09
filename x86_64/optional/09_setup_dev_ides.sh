#!/usr/bin/env bash

# This script sets up dev IDEs

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../lib/sharedfuncs.sh"
bail_on_root

yay_inst_pkg intellij-idea-ultimate-edition
yay_inst_pkg intellij-idea-ultimate-edition-jre
yay_inst_pkg webstorm
yay_inst_pkg webstorm-jre
yay_inst_pkg phpstorm
yay_inst_pkg phpstorm-jre
yay_inst_pkg rubymine
yay_inst_pkg goland
yay_inst_pkg goland-jre

yay_inst_pkg docker
yay_inst_pkg jq

sudo systemctl enable --now docker.service

ADD_USER=$(whoami)
sudo usermod --append --groups docker "${ADD_USER}"

echo "You should reboot now."