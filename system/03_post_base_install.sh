#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_root

# Install yaourt
wget https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz -O - | tar xz -C /tmp
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz -O - | tar xz -C /tmp/

cd /tmp/package-query;makepkg -si
cd /tmp/yaourt;makepkg -si