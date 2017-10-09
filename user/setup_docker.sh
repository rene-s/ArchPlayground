#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_root

sudo tee /etc/modules-load.d/loop.conf <<< "loop"
sudo modprobe loop

sudo pacman -S docker
sudo systemctl start docker.service
sudo systemctl enable docker.service

