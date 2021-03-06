#!/usr/bin/env bash

#set -e

TMP_DIR=$(mktemp -d)
chown -R re:users "$TMP_DIR"
pacman -Q --noconfirm yay 2>/dev/null
RET=$?

if [ $RET != "0" ]; then
  echo "Installing yay..."
  cd "$TMP_DIR" || exit
  git clone https://aur.archlinux.org/yay.git
  chown -R re:users ./yay
  cd yay || exit
  sudo -u re makepkg -si --noconfirm
fi

cd || exit
#rm -rf "$TMP_DIR"

# use all possible cores for subsequent package builds
# shellcheck disable=SC2016
sed -i 's,#MAKEFLAGS="-j[0-9]+",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf

# don't compress the packages built here
sed -i "s,PKGEXT='\.pkg\.tar\.xz',PKGEXT='.pkg.tar',g" /etc/makepkg.conf
