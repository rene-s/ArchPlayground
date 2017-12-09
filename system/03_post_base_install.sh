#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_root

# Install yaourt
wget https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz -O - | tar xz -C /tmp
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz -O - | tar xz -C /tmp/

cd /tmp/package-query;makepkg -si
cd /tmp/yaourt;makepkg -si

# Install pacaur
sudo pacman -S expac yajl --noconfirm
TMP_DIR=`mktemp -d`
cd $TMP_DIR
gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53
curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower
makepkg -i PKGBUILD --noconfirm
curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur
makepkg -i PKGBUILD --noconfirm
cd
rm -rf $TMP_DIR