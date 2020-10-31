#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh

bail_on_root

sudo tee /etc/modules-load.d/loop.conf <<<"loop"
sudo modprobe loop

sudo pacman -S docker docker-compose

sudo usermod -aG docker re
sudo usermod -aG docker st

sudo systemctl start docker.service
sudo systemctl enable docker.service
