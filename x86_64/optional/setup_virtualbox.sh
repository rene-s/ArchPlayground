#!/usr/bin/env bash

# This script sets up a system as VirtualBox host or VirtualBox guest

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh

bail_on_user


# Setup environment
VM=$(dmidecode -s system-product-name)
if [[ $VM == "VirtualBox" ]]; then # system is a VirtualBox guest
  pacman -Q virtualbox-guest-utils 2>/dev/null || pacman -S --noconfirm virtualbox-guest-utils
  pacman -Q xf86-video-vmware 2>/dev/null || pacman -S --noconfirm xf86-video-vmware
  systemctl enable vboxservice.service --now
else # system is a VirtualBox host, note: assumes linux-lts kernel TODO needs check
  pacman -Q virtualbox-host-dkms 2>/dev/null || pacman -S --noconfirm virtualbox-host-dkms
  pacman -Q virtualbox 2>/dev/null || pacman -S --noconfirm virtualbox

  vboxreload

  #sudo usermod -aG vboxusers re
  #sudo usermod -aG vboxusers st
fi

echo "Done."
