#!/usr/bin/env bash

# This script sets up AUR for the system.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../lib/sharedfuncs.sh"
bail_on_user

# Step 1: Install yay
BUILD_DIR=/home/.build
mkdir "${BUILD_DIR}" 2>/dev/null
chgrp nobody "${BUILD_DIR}"
chmod g+ws "${BUILD_DIR}"

# Taken from: http://allanmcrae.com/2015/01/replacing-makepkg-asroot/
setfacl -m u::rwx,g::rwx "${BUILD_DIR}"
setfacl -d --set u::rwx,g::rwx,o::- "${BUILD_DIR}"

TMP_DIR=$(sudo -u nobody mktemp -d --tmpdir="${BUILD_DIR}")

pacman_inst_pkg git
pacman_inst_pkg go

pacman -Q --noconfirm yay 2>/dev/null
RET=$?

if [ $RET != "0" ]; then
  cd "${TMP_DIR}" || exit
  echo "Cloning yay into ${TMP_DIR}..."
  sudo -u nobody mkdir "${BUILD_DIR}/.cache"
  sudo -u nobody git clone https://aur.archlinux.org/yay.git
  cd yay || exit
  echo "Making yay..."
  sudo -u nobody HOME="${BUILD_DIR}" makepkg --noconfirm
  echo "Installing yay..."
  pacman -U $(find . -name "yay*.pkg.tar.zst") --noconfirm
fi

echo "Cleanup yay..."
rm -rf "${TMP_DIR}" "${BUILD_DIR}/yay"

# Step 2: Install some AUR packages.

echo "Done"