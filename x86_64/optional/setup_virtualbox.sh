#!/usr/bin/env bash

# This script sets up a system as VirtualBox host or VirtualBox guest

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh

bail_on_user

pacman -Q virtualbox-guest-dkms 2>/dev/null || pacman -S --noconfirm virtualbox-guest-dkms

# Setup environment
VM=$(dmidecode -s system-product-name)
if [[ $VM == "VirtualBox" ]]; then # system is a VirtualBox guest
  pacman -Q virtualbox-guest-utils 2>/dev/null || pacman -S --noconfirm virtualbox-guest-utils
  pacman -Q xf86-video-vmware 2>/dev/null || pacman -S --noconfirm xf86-video-vmware
  systemctl enable vboxservice.service --now
  systemctl start vboxservice.service --now
else # system is a VirtualBox host
  pacman -Q virtualbox 2>/dev/null || pacman -S --noconfirm virtualbox

  sudo vboxreload

  #sudo usermod -aG vboxusers re
  #sudo usermod -aG vboxusers st
fi

echo "Done."
